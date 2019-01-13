class Player < ApplicationRecord
  has_many :match_scores, foreign_key: "player_id"
end
