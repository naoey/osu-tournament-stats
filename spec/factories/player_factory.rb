FactoryBot.define do
  factory :player do
    name { "nitr0f #{Player.count + 1}" }
    osu_id { Player.count + 1 }
    discord_id { Player.count + 1 }
  end
end
