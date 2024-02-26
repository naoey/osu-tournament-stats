class Player < ApplicationRecord
  # Include default devise modules. Others available are:
  devise(:invitable,
    :database_authenticatable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :lockable,
    :timeoutable,
    :trackable)

  devise :omniauthable, omniauth_providers: %i[osu discord]

  has_many :identities, class_name: 'PlayerAuth'
  has_many :match_scores, foreign_key: 'player_id'
  has_and_belongs_to_many :match_teams
  has_many :hosted_tournaments, foreign_key: 'id', class_name: 'Tournament'
  has_many :ban_history, foreign_key: 'player_id'
  has_many :discord_exp

  enum ban_statuses: { none: 0, soft: 1, hard: 2 }, _prefix: :ban_status

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

    raise ArgumentError, "Only osu! provider is allowed for new user sign ups!" if identity.nil? && auth.provider != 'osu'

    identity = PlayerAuth.create_with_omniauth(auth)

    if identity.player.nil?
      Player.create do |player|
        player.password = Devise.friendly_token[0, 20]
        player.name = auth.info.username
        player.country_code = auth.info[:country_code]
        player.avatar_url = auth.info[:avatar_url]
        player.identities = [identity]

        player.save!
      end
    end

    unless identity.player.confirmed?
      # if it was one of the old migrated users being logged in for the first time, it might still be unconfirmed
      # preventing the user from signing in. consider this login as confirmation that the user is the real owner
      # of the account.
      identity.player.skip_confirmation!
    end

    identity.player
  end

  # Links additional Omniauth identities to this Player. Primarily intended for users to link their
  # Discord account after the fact without invoking the Discord bot.
  def add_additional_account(auth)
    # for now we only support adding discord accounts, so it's just thrown in here
    raise ArgumentError, 'Only Discord is supported as an additional account' if auth.provider != 'discord'

    identity = PlayerAuth.find_with_omniauth(auth)

    raise RuntimeError, 'Discord is already linked. Unlink it first to link a different account.' unless identity.nil?

    identity = PlayerAuth.create_with_omniauth(auth)
    identity.player = self
    identity.save!

    ActiveSupport::Notifications.instrument(
      'player.discord_linked',
      { player: player }
    )
  end

  def as_json(*)
    hash = super.slice('id', 'name', 'avatar_url', 'country_code', 'identities', 'last_sign_in_at', 'ban_status', 'discord_last_spoke', 'created_at')
    hash['identities'] = identities.as_json(include: :auth_provider)
    hash
  end
end
