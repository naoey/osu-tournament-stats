FactoryBot.define do
  factory :match_team do
    name { "Test Team #{rand(1_000_000)}" }
    association :captain, factory: :player

    transient do
      player_count { 1 }
    end

    after(:create) do |team, evaluator|
      create_list(:player, evaluator.player_count, match_teams: [team])
    end
  end
end
