FactoryBot.define do
  factory :player do
    name { "nitr0f #{Player.count + 1}" }
  end
end
