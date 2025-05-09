class PlayerAuth < ApplicationRecord
  belongs_to :player
  belongs_to :auth_provider, foreign_key: :provider
  has_many :other_auths, foreign_key: :player_id, class_name: 'PlayerAuth'

  after_initialize { self.raw ||= {}  }

  def self.find_with_omniauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end

  def self.create_with_omniauth(auth)
    create(provider: auth.provider, uid: auth.uid) do |player_auth|
      player_auth.uname = auth.extra["raw_info"]["username"]
      player_auth.uid = auth.uid
      player_auth.raw = auth.info
    end
  end
end
