FactoryBot.define do
  factory :player do
    name { "nitr0f #{Player.count + 1}" }
    osu_id { Player.count + 1 }
    discord_id { Player.count + 1 }

    factory :player_with_auth_request do
      after(:create) do |player, evaluator|
        create(:osu_auth_request, player: player)

        player.reload
      end
    end
  end
end
