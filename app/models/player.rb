class Player < ApplicationRecord
  has_many :match_scores, foreign_key: 'player_id'
  has_many :player_reds, foreign_key: 'player_red', class_name: 'Match'
  has_many :player_blues, foreign_key: 'player_blue', class_name: 'Match'
  has_many :hosted_tournaments, foreign_key: 'id', class_name: 'Tournament'
end
