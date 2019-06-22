class Tournament < ApplicationRecord
  has_many :matches, foreign_key: 'tournament_id'
end
