class MatchTeam < ApplicationRecord
  has_and_belongs_to_many :players
  belongs_to :captain, class_name: 'Player'

  def as_json(*)
    super.slice('name', 'id').tap do |t|
      t['captain'] = captain.as_json
      t['players'] = players.as_json
    end
  end
end
