FactoryBot.define do
  factory :match do
    round_name { "Test Match #{rand(1000)}" }
    online_id { Match.count + 1 }
  end
end
