class Beatmap < ApplicationRecord
    validates_uniqueness_of :online_id
end
brew