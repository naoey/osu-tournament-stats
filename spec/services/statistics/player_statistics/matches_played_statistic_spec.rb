require "rails_helper"

require_relative "../../../../app/services/statistics/player_statistics.rb"

describe "MatchesPlayedStatisticTest" do
  it "counts matches played correctly" do
    test_player = create(:player)
    other_player = create(:player)

    red_teams = create_list(:match_team, 5, players: [test_player], captain: test_player)
    blue_teams = create_list(:match_team, 5, players: [other_player], captain: other_player)

    red_teams.each_with_index { |team, index| create(:match, red_team: team, blue_team: blue_teams[index], winner: team) }

    expect(PlayerStatistics::MatchesPlayedStatistic.new(test_player).compute).to equal(5)
  end
end
