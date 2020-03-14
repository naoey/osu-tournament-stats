FactoryBot.define do
  factory :match_score do
    association :match
    association :player
    association :beatmap

    transient do
      full_combo? { false }
    end

    max_combo { full_combo? ? beatmap.max_combo : rand(beatmap.max_combo) }
    count_300 { rand(max_combo) }
    count_100 { rand(max_combo - count_300) }
    count_50 { rand(max_combo - count_300 - count_100) }
    count_miss { rand(max_combo - count_300 - count_100 - count_50) }
    count_geki { rand(count_300) }
    count_katu { rand(count_100) }
    perfect { max_combo == beatmap.max_combo }
    # only fail if misses are greater than 0 AND the random boolean says true
    pass { count_miss > 0 && [true, false].sample }
  end
end
