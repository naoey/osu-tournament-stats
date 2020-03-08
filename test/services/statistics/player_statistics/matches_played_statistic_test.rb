require 'test/unit'

class MatchesPlayedStatisticTest < Test::Unit::TestCase
  def test_count_matches_correctly
    test_player_red = Player.create(name: 'Test Red Player', osu_id: 9099, email: 'test_red@naoey.pw')
    test_player_blue = Player.create(name: 'Test Blue Player', osu_id: 9100, email: 'test_blue@naoey.pw')

    test_match_red_team1 = MatchTeam.create(name: 'Test Red Team 1', players: [test_player_red], captain: test_player_red)
    test_match_blue_team1 = MatchTeam.create(name: 'Test Blue Team 1', players: [test_player_blue], captain: test_player_blue)
    test_match_red_team2 = MatchTeam.create(name: 'Test Red Team 2', players: [test_player_red], captain: test_player_red)
    test_match_blue_team2 = MatchTeam.create(name: 'Test Blue Team 2', players: [test_player_blue], captain: test_player_blue)

    test_match1 = Match.create(
      online_id: 9999,
      round_name: 'Test Match 1',
      red_team: test_match_red_team1,
      blue_team: test_match_blue_team1,
    )

    test_match2 = Match.create(
      online_id: 9998,
      round_name: 'Test Match 2',
      red_team: test_match_red_team2,
      blue_team: test_match_blue_team2,
    )

    stat = service(test_player_red).compute

    assert_equal(2, stat)

    test_match1.destroy!
    test_match2.destroy!
    test_match_red_team1.destroy!
    test_match_blue_team1.destroy!
    test_match_red_team2.destroy!
    test_match_blue_team2.destroy!
    test_player_red.destroy!
    test_player_blue.destroy!
  end

  def test_invalid_player_throws
    assert_raise(ArgumentError) do
      service(nil).compute
    end
  end

  private

  def service(player)
    PlayerStatistics::MatchesPlayedStatistic.new(player)
  end
end
