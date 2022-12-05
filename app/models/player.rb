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
         :trackable) && :omniauthable

  has_many :match_scores, foreign_key: 'player_id'
  has_many :osu_auth_requests, foreign_key: 'player_id'
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

  def begin_osu_discord_verification(discord_server)
    OsuAuthRequest.create(player: self, discord_server: discord_server).authorisation_link
  end

  def complete_osu_verification(nonce, osu_api_response)
    auth_request = OsuAuthRequest.find_by(player: self, nonce: nonce)

    logger.debug("Completing auth request #{auth_request.inspect}")

    if auth_request.nil? || auth_request.resolved
      raise StandardError, "No pending authorisation requests found for #{self} with request ID #{nonce}"
    end

    raise OsuAuthErrors::InvalidOsuUserError, 'Cannot verify user with bot account!' if osu_api_response['is_bot']
    raise OsuAuthErrors::InvalidOsuUserError, 'Cannot verify user with deleted osu! account!' if osu_api_response['is_deleted']
    raise OsuAuthErrors::InvalidOsuUserError, 'Cannot verify user with deleted osu! account!' if osu_api_response['is_restricted']

    self.osu_id = osu_api_response['id']
    self.name = osu_api_response['username']
    self.osu_verified = true
    self.osu_verified_on = DateTime.now

    save!

    auth_request.resolved = true
    auth_request.save!

    ActiveSupport::Notifications.instrument 'player.osu_verified', { auth_request: auth_request }
  end

  def as_json(*)
    super.slice('id', 'name', 'osu_id')
  end
end
