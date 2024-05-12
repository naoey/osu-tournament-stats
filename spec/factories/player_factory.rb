FactoryBot.define do
  factory :player do
    name { "nitr0f #{Player.count + 1}" }

    after(:create) { |player|
      player.identities = [
        FactoryBot.create(:player_auth, player: player, provider: :osu),
        FactoryBot.create(:player_auth, player: player, provider: :discord)
      ]
    }
  end
end
