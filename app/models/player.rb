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

  enum :ban_status, { no_ban: 0, soft: 1, hard: 2 }

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

    if identity.nil? && auth.provider != "osu"
      # If the logging in account doesn't already exist we will have to create it, but we don't support registering
      # with anything except osu!, so reject anything else right away.
      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          category: "omniauth.from_omniauth",
          type: "info",
          message: "new non-osu OmniAuth",
          level: "info",
          data: { auth: },
        )
      )

      raise ArgumentError, "Only osu! provider is allowed for new user sign ups!"
    end

    # Sometimes osu! identities may already exist even if the user never actually registered due to having been
    # created for the sake of match imports. In this case we just re-use the same identity. In the case the Player
    # has never been imported through a match, then it's a completely fresh user so we just create it as normal.
    player = identity&.player
    should_notify_linkage = false

    if player.nil?
      # This is a brand new user
      player = Player.create do |p|
        p.password = Devise.friendly_token[0, 20]
        p.name = auth.info.username
        p.country_code = auth.info[:country_code]
        p.avatar_url = auth.info[:avatar_url]
        p.skip_confirmation!
        p.save!

        p.link_osu_discord_identities(auth, state) unless state.nil?
      end
    elsif auth.provider == 'osu'
      # Update name from osu! logins even for existing users
      player.name = auth.info.username
      player.country_code = auth.info[:country_code]
      player.avatar_url = auth.info[:avatar_url]

      player.identities.where(provider: :osu).update(uname: auth.info.username, raw: auth.info)
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
    Sentry.add_breadcrumb(
      Sentry::Breadcrumb.new(
        category: "omniauth.add_additional_account",
        type: "info",
        message: "Adding secondary account",
        level: "info",
        data: { auth: },
      )
    )

    # for now we only support adding discord accounts as additional, so it's just thrown in here because idk
    raise ArgumentError, "Only Discord is supported as an additional account" if auth.provider != "discord"

    identity = PlayerAuth.find_with_omniauth(auth)

    unless identity&.player.player_auths.find_by_provider(:osu).nil?
      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          category: "omniauth.add_additional_account",
          type: "info",
          message: "Discord ID is already linked to an osu!",
          level: "info",
          data: { auth: },
        )
      )
    end

    raise "Discord is already linked. Unlink it first to link a different account." unless identity.nil? || identity.player.player_auths.find_by_provider(:osu).nil?

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
  def link_osu_discord_identities(auth, state)
    discord_id, guid = Base64.decode64(state).split("|")

    saved_state = Rails.cache.read("discord_bot/osu_verification_links/#{discord_id}")

    raise OsuAuthErrors::TimeoutError if saved_state.nil?

    discord_user = saved_state["user"]
    osu_user = auth.info

    raise OsuAuthErrors::UnauthorisedError if saved_state["guid"] != guid
    raise OsuAuthErrors::UnauthorisedError if discord_user["id"] != discord_id.to_i

    discord_identity = PlayerAuth.find_by_uid(discord_user["id"])

    identities.build(provider: :osu, uid: osu_user["id"], uname: osu_user["username"], raw: osu_user).save!

    if discord_identity.nil?
      identities.build(provider: :discord, uid: discord_user["id"], uname: discord_user["username"], raw: discord_user).save!
    else
      ActiveRecord::Base.transaction do
        transient_player = discord_identity.player
        discord_identity.player = self
        discord_identity.save!
        self.discord_exp = transient_player.discord_exp
        self.save!
        transient_player.destroy!
      end
    end

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

  def notify_alt_account_link(other_player)
    begin
      ActiveSupport::Notifications.instrument("player.alt_link", { player: self, other_player: })
    rescue StandardError => e
      Rails.logger.error("Notification handler error\n#{e.backtrace.join('\r\n')}")
    end
  end
end
