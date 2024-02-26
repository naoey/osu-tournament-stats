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

  devise :omniauthable, omniauth_providers: %i[osu]

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

  def self.from_osu_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.username
      user.osu_id = auth.info.id

      user.skip_confirmation!
    end
  end

  def as_json(*)
    super.slice('id', 'name', 'osu_id')
  end
end
