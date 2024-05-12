FactoryBot.define do
  factory :player_auth do
    uid { PlayerAuth.count + 1 }
    uname { "nitr0f" }
  end
end
