require "rails_helper"

require_relative "../../../../app/services/statistics/player_statistics.rb"

describe "AverageAccuracyStatisticTest" do
  it "counts average accuracy correctly" do
    player = create(:player)
    scores = create_list(:match_score, 5, player: player, count_miss: 7)

    expected_acc = scores.map { |s| StatCalculationHelper.calculate_accuracy(s) }.reduce(:+)

    expected_acc /= scores.size.to_f

    expect(PlayerStatistics::AverageAccuracyStatistic.new(player).compute).to equal(expected_acc.round(4))
  end

  it "returns 0 for no scores" do
    player = create(:player)

    expect(PlayerStatistics::AverageAccuracyStatistic.new(player).compute).to equal(0)
  end
end
