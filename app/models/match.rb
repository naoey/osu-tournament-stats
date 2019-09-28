class Match < ApplicationRecord
  belongs_to :player_red, class_name: 'Player'
  belongs_to :player_blue, class_name: 'Player'
  belongs_to :winner, class_name: 'MatchTeam'
  belongs_to :tournament

  has_one :red_team, class_name: 'MatchTeam', dependent: :delete, inverse_of: :match
  has_one :blue_team, class_name: 'MatchTeam', dependent: :delete, inverse_of: :match
  has_many :match_scores, foreign_key: 'match_id', dependent: :delete_all

  validates_uniqueness_of :online_id
end
