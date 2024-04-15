FactoryBot.define do
  factory :match do
    round_name { "Test Match #{rand(1000)}" }
    online_id { Match.count + 1 }

    association :red_team, factory: :match_team
    association :blue_team, factory: :match_team
    association :winner, factory: :match_team

    after(:create) { |match| match.winner = [match.red_team, match.blue_team].sample }
  end
end
