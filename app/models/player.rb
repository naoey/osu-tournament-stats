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

  SENSITIVE_ATTRIBUTES = %i[email encrypted_password reset_password_token confirmation_token unlock_token invitation_token].freeze

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

  def self.from_omniauth(auth)
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

    if player.nil?
      # This is a brand new user
      player = Player.from_osu_auth(auth)
    else
      # Update name from osu! logins even for existing users
      player.name = auth.info[:username]
      player.country_code = auth.info[:country_code]
      player.avatar_url = auth.info[:avatar_url]

      player.identities.where(provider: :osu).update(uname: auth.info[:username], raw: auth.info)
    end

    unless player.confirmed?
      # if it was one of the old migrated users being logged in for the first time, it might still be unconfirmed
      # preventing the user from signing in. consider this login as confirmation that the user is the real owner
      # of the account.
      player.skip_confirmation!
    end

    player.save!

    return player
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

    unless identity&.player.identities.find_by_provider(:osu).nil?
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
  def self.get_osu_verification_link(discord_user, guild)
    guid = SecureRandom.uuid
    Rails.cache.write(
      "discord_bot/osu_verification_links/#{discord_user["id"]}",
      { guid:, user: discord_user, guild: }.stringify_keys,
      expires_in: 5.minutes
    )

    state = Base64.encode64("#{discord_user["id"]}|#{guid}")
    Rails.application.routes.url_helpers.polymorphic_url(:users_register_discord, f: "bot", s: state)
  end

  def as_json(*)
    hash = super(include: %i[discord_exp ban_history]).except(*SENSITIVE_ATTRIBUTES.map(&:to_s))
    hash["identities"] = identities.as_json(include: :auth_provider, except: :raw_info)
    hash["ban_history"] = ban_history.as_json(include: :banned_by)
    hash["discord_exp"] = discord_exp.as_json(include: :discord_server)
    hash
  end

  # Links a pair of osu! x Discord IDs, concluding the flow started by `get_osu_verification_link`. This is a different
  # process than a regular login using either service and will fail if the osu! account is found to already be linked
  # to another Discord account, and notify the server from which the verification request was started.
  def self.from_bot_link(omniauth, state)
    discord_id, guid = Base64.decode64(state).split("|")
    cache_key = "discord_bot/osu_verification_links/#{discord_id}"
    saved_state = Rails.cache.read(cache_key)

    raise OsuAuthErrors::TimeoutError, "Verification timed out" if saved_state.nil?

    Rails.cache.delete(cache_key)

    guild = DiscordServer.find_by_discord_id(saved_state["guild"]["discord_id"])

    if guild.nil?
      logger.error("Guild is nil for bot link request completion", osu_auth: omniauth, state: state, cached_state: saved_state)
      raise OsuAuthErrors::OsuAuthError, "Something is wrong. Contact the server admins."
    end

    discord_user = saved_state["user"]
    osu_auth = PlayerAuth.find_by(provider: :osu, uid: omniauth.uid)

    raise OsuAuthErrors::UnauthorisedError, "Something is wrong. Contact the server admins." if saved_state["guid"] != guid
    raise OsuAuthErrors::UnauthorisedError, "Something is wrong. Contact the server admins." if discord_user["id"] != discord_id.to_i

    if osu_auth.nil?
      # This osu! user doesn't exist in our system, handle linkage normally
      logger.info("osu account is not found; handling linkage normally")

      player = Player.from_osu_auth(omniauth)

      # If the Discord identity already exists (it probably should due to exp thingo), fold it into this newly created
      # osu! auth owner
      discord_auth = PlayerAuth.find_by(provider: :discord, uid: discord_id.to_i)

      if discord_auth.nil?
        # If for some reason it doesn't exist, create it
        logger.info("Discord auth doesn't exist; creating")
        player.identities
              .build(provider: :discord, uid: discord_user["id"], uname: discord_user["username"], raw: discord_user)
              .save!
      else
        old_discord_player = discord_auth.player
        discord_auth.player = player

        Player.verify_exp_exist_and_merge(player, old_discord_player, guild)

        discord_auth.save!
        old_discord_player.destroy!

        logger.info("Finished folding Discord auth into osu! auth", player.identities.inspect)
      end

      player.save!

      ApplicationHelper::Notifications.notify("player.discord_linked", { player: })

      return player
    end

    player = osu_auth.player

    if !player.discord.nil? && player.discord.uid == discord_id.to_i
      # We should never be here because this should have already been handled by the bot before initiating the flow
      logger.warn("Someone is messing about; player re-link attempt", { player:, osu_auth:, saved_state: })
      raise OsuAuthErrors::UnauthorisedError, "What are you trying to do?"
    end

    if !player.discord.nil? && player.discord.uid != discord_id.to_i
      logger.warn("Alt verification attempt", { osu_auth:, state:, cached_state: saved_state })
      ApplicationHelper::Notifications.notify(
        "player.alt_link",
        { player:, guild:, alt_discord: discord_user }
      )
      raise OsuAuthErrors::AltAccountError, "osu! account is already linked to another Discord user."
    end

    discord_auth = PlayerAuth.find_by_uid(discord_user["id"])

    if discord_auth.nil?
      # The Discord ID hasn't been claimed by anyone; create the identity and link it to the osu player
      logger.info('Discord ID not found; handling linkage normally')

      osu_auth
        .player
        .identities
        .build(
          provider: :discord,
          uid: discord_user["id"],
          uname: discord_user["username"],
          raw: discord_user
        )
        .save!

      ApplicationHelper::Notifications.notify("player.discord_linked", { player: })

      return player
    end

    # Now the troublesome one where osu and Discord are linked to different players, and neither of them have
    # the other identity. In this case, fold the player owning the Discord ID into the player owning the osu! ID
    logger.info("Merging Discord player into current osu player", { discord_player: discord_auth.player.id, osu_player: osu_auth.player.id })
    ActiveRecord::Base.transaction do
      transient_player = discord_auth.player
      discord_auth.player = osu_auth.player
      discord_auth.save!

      Player.verify_exp_exist_and_merge(player, transient_player, guild)

      player.save!
      transient_player.destroy!
    end

    ApplicationHelper::Notifications.notify("player.discord_linked", { player: })

    return player
  end

  private

  ##
  # DONT FLIP THE PLAYER1 and 2 ORDER
  def self.verify_exp_exist_and_merge(player1, player2, guild)
    exp = player1.discord_exp.find_or_create_by(discord_server_id: guild.id, player_id: player1.id) do |e|
      e.detailed_exp = DiscordHelper::INITIAL_EXP.clone
    end

    if player2.discord_exp.nil?
      # The temporary player also doesn't have any exp, initialise a new one
      exp.exp = 0
      exp.level = 0
      exp.message_count = 0
      exp.player = player1
      exp.save!
    else
      exp.merge(player2.discord_exp.find_by(discord_server_id: guild.id))
    end
  end

  def self.from_osu_auth(auth)
    if auth.provider != 'osu'
      raise RuntimeError "Attempting to create user from osu auth but provider is not osu -- #{auth.inspect}"
    end

    player = PlayerAuth.find_by(provider: :osu, uid: auth.uid)&.player

    if player.nil?
      player = Player.create do |p|
        p.password = Devise.friendly_token[0, 20]
        p.name = auth.info[:username]
        p.country_code = auth.info[:country_code]
        p.avatar_url = auth.info[:avatar_url]
        p.skip_confirmation!
        p.identities.build(
          provider: :osu,
          uid: auth.uid,
          uname: auth.info[:username],
          raw: auth.info
        )
        p.save!
      end
    end

    return player
  end

  def notify_discord_linked

  end
end
