require "rails_helper"

require_relative "../../../../app/services/statistics/player_statistics.rb"

describe "PlayerStatisticTest" do
  context "when invalid initialisation" do
    it "throws error for initialisation with nil Player" do
      expect { PlayerStatistics::PlayerStatistic.new(nil) }.to raise_error(ArgumentError)
    end

    it "throws error for initialisation with non-Player type argument" do
      expect { PlayerStatistics::PlayerStatistic.new(build(:match)) }.to raise_error(ArgumentError)
    end
  end

  context "when valid initialisation" do
    it "builds without errors" do
      expect { PlayerStatistics::PlayerStatistic.new(build(:player)) }.not_to raise_error
    end
  end
end
