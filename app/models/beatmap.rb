class Beatmap < ApplicationRecord
    has_many :match_score, foreign_key: :beatmap_id

    validates_uniqueness_of :online_id
end
