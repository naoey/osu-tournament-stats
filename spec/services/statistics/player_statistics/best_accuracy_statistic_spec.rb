require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'BestAccuracyStatisticTest' do
  it 'counts best accuracy correctly' do
    player = create(:player)
    scores = create_list(:match_score, 5, player: player, count_miss: 7)

    expected_acc = scores.map { |s| AccuracyHelper.calculate_accuracy(s) }.max.round(4)

    expect(PlayerStatistics::BestAccuracyStatistic.new(player).compute).to equal(expected_acc)
  end

  it 'returns 0 for no scores' do
    player = create(:player)

    expect(PlayerStatistics::BestAccuracyStatistic.new(player).compute).to equal(0)
  end
end
