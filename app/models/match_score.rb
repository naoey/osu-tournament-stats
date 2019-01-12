class MatchScore < ApplicationRecord
  :validates_uniqueness_of :match_id, scope: [:player_id, :beatmap_id]
end
