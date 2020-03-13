require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'BestAccuracyStatisticTest' do
  it 'counts average misses correctly' do
    player = create(:player)
    scores = create_list(:match_score, 5, player: player, count_miss: 7)

    calc = AccuracyCalculator.new
    expected_acc = scores.map { |s| calc.calculate_accuracy(s) }.max.round(4)

    expect(PlayerStatistics::BestAccuracyStatistic.new(player).compute).to equal(expected_acc)
  end

  it 'returns 0 for no scores' do
    player = create(:player)

    expect(PlayerStatistics::BestAccuracyStatistic.new(player).compute).to equal(0)
  end

  private

  class AccuracyCalculator
    include AccuracyHelper

    attr_reader :calculate_accuracy
  end
end
