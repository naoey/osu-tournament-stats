FactoryBot.define do
  factory :osu_auth_request do
    association :player
    association :discord_server

    resolved { 0 }
    nonce { SecureRandom.uuid }
  end
end
