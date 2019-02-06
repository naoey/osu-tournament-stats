class MatchScore < ApplicationRecord
  belongs_to :player, foreign_key: "player_id"
  has_one :beatmap, foreign_key: "beatmap_id", primary_key: "online_id"
  belongs_to :match, foreign_key: "match_id"

  validates_uniqueness_of :match_id, scope: [:player_id, :beatmap_id]
end
