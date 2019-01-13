class Match < ApplicationRecord
    belongs_to :player_red, class_name: "Player", foreign_key: "player_red"
    belongs_to :player_blue, class_name: "Player", foreign_key: "player_blue"

    validates_uniqueness_of :online_id
end
