require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'TotalMissesStatisticTest' do
  it 'counts total misses correctly' do
    player = create(:player)
    create_list(:match_score, 10, count_miss: 10, player: player)

    expect(PlayerStatistics::TotalMissesStatistic.new(player).compute).to equal(10 * 10)
  end

  it 'returns 0 when there are no scores to count' do
    player = create(:player)

    expect(PlayerStatistics::TotalMissesStatistic.new(player).compute).to equal(0)
  end
end
