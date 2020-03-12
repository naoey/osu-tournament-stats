require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'MatchesPlayedStatistic' do
  context 'when invalid initialisation'
  it 'throws error' do
    expect { PlayerStatistics::MatchesPlayedStatistic.new(nil).compute }.to raise_error(ArgumentError)
  end

  context 'when valid initialisation'
  it 'should count matches played correctly' do
    test_player = create(:player)
    other_player = create(:player)

    red_teams = create_list(:match_team, 5, players: [test_player], captain: test_player)
    blue_teams = create_list(:match_team, 5, players: [other_player], captain: other_player)

    red_teams.each_with_index do |team, index|
      create(:match, red_team: team, blue_team: blue_teams[index], winner: team)
    end

    expect(PlayerStatistics::MatchesPlayedStatistic.new(test_player).compute).to equal(5)
  end
end
