class Match < ApplicationRecord
    belongs_to :player_red, class_name: "Player", foreign_key: "player_red"
    belongs_to :player_blue, class_name: "Player", foreign_key: "player_blue"
    has_many :match_scores, foreign_key: "match_id"

    validates_uniqueness_of :online_id
end
