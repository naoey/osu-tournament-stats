class MatchScore < ApplicationRecord
  belongs_to :player, foreign_key: "player_id"
  belongs_to :beatmap, foreign_key: "beatmap_id", primary_key: "online_id"

  validates_uniqueness_of :match_id, scope: [:player_id, :beatmap_id]
end
