class Match < ApplicationRecord
  belongs_to :winner, class_name: 'MatchTeam', optional: true
  belongs_to :tournament, optional: true
  belongs_to :red_team, class_name: 'MatchTeam', dependent: :destroy
  belongs_to :blue_team, class_name: 'MatchTeam', dependent: :destroy

  has_many :match_scores, foreign_key: 'match_id', dependent: :delete_all

  validates_uniqueness_of :online_id

  def players
    red_team.players + blue_team.players
  end

  def as_json(*)
    super.except('winner_id', 'created_at', 'updated_at', 'red_team_id', 'blue_team_id').tap do |m|
      m['winning_team'] = winner.as_json
      m['red_team'] = red_team.as_json
      m['blue_team'] = blue_team.as_json
    end
  end
end
