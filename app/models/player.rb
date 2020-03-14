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
  has_and_belongs_to_many :match_teams
  has_many :hosted_tournaments, foreign_key: 'id', class_name: 'Tournament'

  def email_required?
    # new_record? ? false : super
    false
  end

  def password_required?
    # new_record? ? false : super
    false
  end

  def as_json(*)
    super.slice('id', 'name', 'osu_id')
  end
end
