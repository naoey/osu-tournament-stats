require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'FullCombosStatisticTest' do
  it 'counts perfect combos as full combo' do
    player = create(:player)
    create_list(:match_score, 5, player: player, full_combo?: true, count_miss: 0)

    expect(PlayerStatistics::FullCombosStatistic.new(player).compute).to equal(5)
  end

  # todo: this should be re-implemented in the parser to validate this logic is working correctly when
  # being inserted into is_full_combo column
  xit 'counts scores with no misses and <=1% missed combo as FC' do
    player = create(:player)
    beatmap = create(:beatmap, max_combo: 1500)
    score = create(:match_score, player: player, count_miss: 0, beatmap: beatmap)

    # exactly 1%
    score.max_combo = beatmap.max_combo - 15
    score.save!

    expect(PlayerStatistics::FullCombosStatistic.new(player).compute).to equal(1)

    # less than 1%
    score.max_combo = beatmap.max_combo - 13
    score.save!

    expect(PlayerStatistics::FullCombosStatistic.new(player).compute).to equal(1)

    # greater than 1%
    score.max_combo = beatmap.max_combo - 16
    score.save!

    expect(PlayerStatistics::FullCombosStatistic.new(player).compute).to equal(0)
  end
end
