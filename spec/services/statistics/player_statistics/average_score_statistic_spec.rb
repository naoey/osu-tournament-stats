require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'AverageScoreStatisticTest' do
  it 'counts average score correctly' do
    @scores = []

    def generate_score
      s = rand(100_000_000)

      @scores.push(s)
      s
    end

    player = create(:player)
    create_list(:match_score, 5, score: generate_score, player: player)

    expect(PlayerStatistics::AverageScoreStatistic.new(player).compute).to equal((@scores.reduce(:+) / @scores.size.to_f).round(2))
  end

  it 'returns 0 when there are no scores' do
    player = create(:player)

    expect(PlayerStatistics::AverageScoreStatistic.new(player).compute).to equal(0.0)
  end
end
