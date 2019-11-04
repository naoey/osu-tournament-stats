class MatchScore < ApplicationRecord
  belongs_to :player, foreign_key: 'player_id'
  belongs_to :beatmap, foreign_key: 'beatmap_id'
  belongs_to :match, foreign_key: 'match_id', optional: false

  validates_uniqueness_of :match_id, scope: %i[player_id beatmap_id]
end
