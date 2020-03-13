FactoryBot.define do
  factory :beatmap do
    online_id { Beatmap.count + 1 }
    name { "Test Beatmap #{rand(1_000_000)}" }
    max_combo { rand(10_000) }
    star_difficulty { rand(10) / 100.to_f }
    difficulty_name { "Test diff" }
  end
end
