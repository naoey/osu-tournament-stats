require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'TotalScoreStatisticTest' do
  it 'counts total score correctly' do
    SCORE = 100_000_000

    player = create(:player)
    create_list(:match_score, 5, score: SCORE, player: player)

    expect(PlayerStatistics::TotalScoreStatistic.new(player).compute).to equal(SCORE * 5)
  end

  it 'should return 0 when there are no scores' do
    player = create(:player)

    expect(PlayerStatistics::TotalScoreStatistic.new(player).compute).to equal(0)
  end
end
