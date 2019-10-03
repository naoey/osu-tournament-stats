class Match < ApplicationRecord
  belongs_to :winner, class_name: 'MatchTeam'
  belongs_to :tournament

  belongs_to :red_team, class_name: 'MatchTeam', dependent: :delete
  belongs_to :blue_team, class_name: 'MatchTeam', dependent: :delete
  has_many :match_scores, foreign_key: 'match_id', dependent: :delete_all

  validates_uniqueness_of :online_id

  def as_json(*)
    super.except('winner_id', 'created_at', 'updated_at').tap do |m|
      m['winning_team'] = winner.as_json
      m['red_team'] = red_team.as_json
      m['blue_team'] = blue_team.as_json
    end
  end
end
