class Match < ApplicationRecord
    :belongs_to :player_red, class_name: "Player"
    :belongs_to :player_blue, class_name: "Player"
end
