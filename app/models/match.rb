class Match < ApplicationRecord
    belongs_to :player_red, class_name: "Player"
    belongs_to :player_blue, class_name: "Player"
    belongs_to :tournament

    has_many :match_scores, foreign_key: "match_id", dependent: :delete_all

    validates_uniqueness_of :online_id
end
