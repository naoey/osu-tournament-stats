FactoryBot.define do
  factory :match_team do
    name { "Test Team #{rand(1000000)}" }

    transient do
      player_count { 1 }
    end

    after(:create) do |team, evaluator|
      create_list(:player, evaluator.player_count, team)
    end
  end
end
