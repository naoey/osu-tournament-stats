require "rails_helper"

require_relative "../../../../app/services/statistics/player_statistics.rb"

describe "PerfectCountStatisticTest" do
  it "counts average misses correctly" do
    player = create(:player)
    create_list(:match_score, 5, player: player, perfect: true)

    expect(PlayerStatistics::PerfectCountStatistic.new(player).compute).to equal(5)
  end

  it "returns 0 for no scores" do
    player = create(:player)

    expect(PlayerStatistics::PerfectCountStatistic.new(player).compute).to equal(0)
  end
end
