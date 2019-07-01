class Player < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :match_scores, foreign_key: "player_id"
  has_many :player_reds, foreign_key: "player_red", class_name: "Match"
  has_many :player_blues, foreign_key: "player_blue", class_name: "Match"
end
