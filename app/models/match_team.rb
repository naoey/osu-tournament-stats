class MatchTeam < ApplicationRecord
  has_and_belongs_to_many :players
  belongs_to :captain, class_name: 'Player'
  belongs_to :match, class_name: 'Match'
end
