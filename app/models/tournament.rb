class Tournament < ApplicationRecord
  has_many :matches, foreign_key: "tournament_id"
  belongs_to :host_player, foreign_key: "host_player_id", class_name: "Player"
end
