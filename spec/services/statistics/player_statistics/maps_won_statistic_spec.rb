require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'MapsWonStatisticTest' do
  it 'counts maps won correctly' do
    test_player = create(:player)
    other_player = create(:player)

    red_teams = create_list(:match_team, 5, players: [test_player], captain: test_player)
    blue_teams = create_list(:match_team, 5, players: [other_player], captain: other_player)

    red_teams.each_with_index do |team, index|
      beatmap = create(:beatmap)
      match = create(:match, red_team: team, blue_team: blue_teams[index], winner: team)
      create(:match_score, player: test_player, match: match, beatmap: beatmap, score: 100_000_000, is_win: true)
      create(:match_score, player: other_player, match: match, beatmap: beatmap, score: 50_000_000, is_win: false)
    end

    puts "Test player #{MatchScore.where(is_win: true).count(:all)}"

    expect(PlayerStatistics::MapsWonStatistic.new(test_player).compute).to equal(5)
  end
end
