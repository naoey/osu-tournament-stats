class Beatmap < ApplicationRecord
  has_many :match_scores, foreign_key: :beatmap_id

  validates_uniqueness_of :online_id

  def as_json(*)
    super.except('created_at', 'updated_at')
  end
end
