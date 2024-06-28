require "base64"

require_relative "../errors/osu_auth_errors"

class Player < ApplicationRecord
  # Include default devise modules. Others available are:
  devise(
    :invitable,
    :database_authenticatable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :lockable,
    :timeoutable,
    :trackable
  )

  devise :omniauthable, omniauth_providers: %i[osu discord]

  has_many :identities, class_name: "PlayerAuth"
  has_many :match_scores, foreign_key: "player_id"
  has_and_belongs_to_many :match_teams
  has_many :hosted_tournaments, foreign_key: "id", class_name: "Tournament"
  has_many :ban_history, foreign_key: "player_id"
  has_many :discord_exp

  enum ban_statuses: { none: 0, soft: 1, hard: 2 }, _prefix: :ban_status

  def discord
    identities.find_by_provider(:discord)
  end

  def osu
    identities.find_by_provider(:osu)
  end

  def email_required?
    # new_record? ? false : super
    false
  end

  def password_required?
    # new_record? ? false : super
    false
  end

  def self.from_omniauth(auth, state: nil)
    identity = PlayerAuth.find_with_omniauth(auth)

    raise ArgumentError, "Only osu! provider is allowed for new user sign ups!" if identity.nil? && auth.provider != "osu"

    # Sometimes osu! identities may already exist even if the user never actually registered due to having been
    # created for the sake of match imports. In this case we just re-use the same identity. In the case the Player
    # has never been imported through a match, then it's a completely fresh user so we just create it as normal.
    player = identity&.player

    if player.nil?
      # This is a brand new user; create a Player for them
      player = Player.create do |p|
        p.password = Devise.friendly_token[0, 20]
        p.skip_confirmation!

        p.create_discord_osu_identities(auth, state)

        p.save!
      end
    end

    # Capture osu info every time login is done with osu!
    if auth.provider == 'osu'
      player.name = auth.info.username
      player.country_code = auth.info[:country_code]
      player.avatar_url = auth.info[:avatar_url]

      identities.where(provider: :osu).update(uname: auth.info.username, raw: auth.info)
    end

    unless player.confirmed?
      # if it was one of the old migrated users being logged in for the first time, it might still be unconfirmed
      # preventing the user from signing in. consider this login as confirmation that the user is the real owner
      # of the account.
      player.skip_confirmation!
    end

    player.save!
    player
  end

  # Links additional Omniauth identities to this Player. Primarily intended for users to link their
  # Discord account after the fact without invoking the Discord bot.
  def add_additional_account(auth)
    x
    # for now we only support adding discord accounts, so it's just thrown in here
    raise ArgumentError, "Only Discord is supported as an additional account" if auth.provider != "discord"

    identity = PlayerAuth.find_with_omniauth(auth)

    raise "Discord is already linked. Unlink it first to link a different account." unless identity.nil?

    identity = PlayerAuth.create_with_omniauth(auth)
    identity.player = self
    identity.save!

    return if osu.nil? # Don't bother notifying Discord linkage when there's no osu! account linked

    notify_osu_discord_linkage
  end

  def remove_additional_account(provider)
    raise ArgumentError, "Unlinking osu! account is not allowed" if provider == "osu"

    id = identities.find_by_provider(provider)

    raise ArgumentError, "Provider #{provider} is not linked" if id.nil?

    id.destroy!
  end

  # Creates a special link to complete osu! verification and OAuth registration with implicit Discord verification
  # by virtue of beginning the process through the Discord bot. This link has an expiry duration of 5 minutes to complete
  # the osu! registration.
  def self.get_osu_verification_link(discord_user)
    guid = SecureRandom.uuid
    Rails.cache.write(
      "discord_bot/osu_verification_links/#{discord_user["id"]}",
      { guid:, user: discord_user }.stringify_keys,
      expires_in: 5.minutes
    )

    state = Base64.encode64("#{discord_user["id"]}|#{guid}")
    Rails.application.routes.url_helpers.polymorphic_url(:users_register_discord, f: "bot", s: state)
  end

  def as_json(*)
    hash = super.as_json(include: %i[discord_exp ban_history])
    hash["identities"] = identities.as_json(include: :auth_provider, except: :raw_info)
    hash["ban_history"] = ban_history.as_json(include: :banned_by)
    hash["discord_exp"] = discord_exp.as_json(include: :discord_server)
    hash
  end

  # Creates a pair of Discord and osu! PlayerAuths for the completion of an Discord x osu! linkage initiated
  # through the bot. Throws if the link session has expired or the initiating user or hash mismatches
  def create_discord_osu_identities(auth, state)
    discord_id, guid = Base64.decode64(state).split("|")

    saved_state = Rails.cache.read("discord_bot/osu_verification_links/#{discord_id}")

    raise OsuAuthErrors::TimeoutError if saved_state.empty?

    discord_user = saved_state["user"]
    osu_user = auth.info

    raise OsuAuthErrors::OsuAuthError, "Already exists" if identities.exists?(uid: [discord_user["id"], osu_user["id"]])

    raise OsuAuthErrors::UnauthorisedError if saved_state["guid"] != guid
    raise OsuAuthErrors::UnauthorisedError if discord_user["id"] != discord_id.to_i

    identities.build(provider: :osu, uid: osu_user["id"], uname: osu_user["username"], raw: osu_user).save!
    identities.build(provider: :discord, uid: discord_user["id"], uname: discord_user["username"], raw: discord_user).save!

    notify_osu_discord_linkage
    nil
  end

  private

  def notify_osu_discord_linkage
    begin
      ActiveSupport::Notifications.instrument("player.discord_linked", { player: self })
    rescue StandardError => e
      Rails.logger.error("Notification handler error\n#{e.backtrace.join('\r\n')}")
    end
  end
end
