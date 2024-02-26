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

  def self.from_osu_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.username
      user.osu_id = auth.info.id
      user.osu_registered_on = DateTime.now
      user.osu_profile = auth.info
      user.country_code = auth.info[:country_code]

      user.skip_confirmation!
    end
  end

  def as_json(*)
    super.slice('id', 'name', 'osu_id')
  end
end
