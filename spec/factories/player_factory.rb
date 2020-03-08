FactoryBot.define do
  factory :player do
    name { 'nitr0f' }
    osu_id { rand(100_000) }
    discord_id { rand(100_000) }
  end
end
