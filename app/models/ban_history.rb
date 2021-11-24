class BanHistory < ApplicationRecord
  belongs_to :player
  belongs_to :banned_by, foreign_key: 'banned_by_id', class_name: 'Player'

  enum ban_types: { none: 0, soft: 1, hard: 2 }, _prefix: :ban_type
end
