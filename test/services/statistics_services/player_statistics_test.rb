require 'test/unit'

class PlayerStatisticsTest < Test::Unit::TestCase
  def test_tournament_statistics_single_player_team
    red_captain = Player.create(osu_id: 2, name: 'Player1', email: 'test1@test.com')
    blue_captain = Player.create(osu_id: 3, name: 'Player2', email: 'test2@test.com')
    tournament = Tournament.create(host_player_id: red_captain.id, name: 'Test Tournament')
    match = Match.create(round_name: 'Test Team 1', online_id: 1, tournament: tournament)
    red_team = MatchTeam.create(players: [red_captain], captain: red_captain, name: 'Red team')
    blue_team = MatchTeam.create(players: [blue_captain], captain: blue_captain, name: 'Blue team')

    match.red_team = red_team
    match.blue_team = blue_team
    match.winner = red_team

    match.save!

    red_team.match_id = blue_team.match_id = match.id

    red_team.save!
    blue_team.save!

    beatmap1 = Beatmap.create(online_id: 1, name: 'Test Beatmap', max_combo: 1900)
    beatmap2 = Beatmap.create(online_id: 2, name: 'Test Beatmap 2', max_combo: 1900)
    beatmap3 = Beatmap.create(online_id: 3, name: 'Test Beatmap 3', max_combo: 1900)

    create_match_score(red_captain, beatmap1, match, 999_999_999)
    create_match_score(red_captain, beatmap2, match, 111_111_111)
    create_match_score(red_captain, beatmap3, match, 777_777_777)
    create_match_score(blue_captain, beatmap1, match, 333_333_333)
    create_match_score(blue_captain, beatmap2, match, 555_555_555)
    create_match_score(blue_captain, beatmap3, match, 222_222_222)

    red_stats, blue_stats = service.get_all_player_stats_for_tournament(tournament.id)

    assert_equal(red_stats[:maps_played], 3)
    assert_equal(blue_stats[:maps_played], 3)

    assert_equal(red_stats[:maps_won], 2)
    assert_equal(blue_stats[:maps_won], 1)

    assert_equal(red_stats[:matches_played], 1)
    assert_equal(blue_stats[:matches_played], 1)

    assert_equal(red_stats[:matches_won], 1)
    assert_equal(blue_stats[:matches_won], 0)

    assert_equal(999_999_999 + 111_111_111 + 777_777_777, red_stats[:total_score])
    assert_equal(333_333_333 + 555_555_555 + 222_222_222, blue_stats[:total_score])

    MatchScore.where(match: match).destroy_all!
    beatmap1.destroy!
    beatmap2.destroy!
    beatmap3.destroy!
    match.destroy!
    red_team.destroy!
    blue_team.destroy!
    red_captain.destroy!
    blue_captain.destroy!
    tournament.destroy!
  end

  private

  def create_match_score(player, beatmap, match, score)
    MatchScore.create(
      match: match,
      beatmap: beatmap,
      online_game_id: 999,
      player: player,
      score: score,
      max_combo: 999_999_999,
      count_50: 999_999_999,
      count_100: 999_999_999,
      count_300: 999_999_999,
      count_geki: 999_999_999,
      count_katu: 999_999_999,
      count_miss: 999_999_999,
      perfect: true,
      pass: true,
    )
  end

  def service
    StatisticsServices::PlayerStatistics.new
  end
end
