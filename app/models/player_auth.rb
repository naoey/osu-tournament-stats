class PlayerAuth < ApplicationRecord
  belongs_to :player
  belongs_to :auth_provider, foreign_key: :provider

  def self.find_with_omniauth(auth)
    player_auth = find_by(uid: auth.uid, provider: auth.provider)
    player_auth.raw = auth.info if player_auth.raw.nil? # capture the profile in case this is one of the old migrated users
    player_auth.save
    player_auth
  end

  def self.create_with_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |player_auth|
      player_auth.uname = auth.username
      player_auth.uid = auth.uid
      player_auth.raw = auth.info
    end
  end
end
