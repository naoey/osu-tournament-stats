require "rails_helper"

require_relative "../../../../app/services/statistics/player_statistics.rb"

describe "AverageMissesStatisticTest" do
  it "counts average misses correctly" do
    player = create(:player)
    create_list(:match_score, 5, player: player, count_miss: 7)

    expect(PlayerStatistics::AverageMissesStatistic.new(player).compute).to equal(7.0)
  end

  it "returns 0 for no scores" do
    player = create(:player)

    expect(PlayerStatistics::AverageMissesStatistic.new(player).compute).to equal(0.0)
  end
end
