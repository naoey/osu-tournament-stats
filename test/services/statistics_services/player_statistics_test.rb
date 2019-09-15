require 'test/unit'

class PlayerStatisticsTest < Test::Unit::TestCase
  def test_match_leaderboard_no_scores
    r = service.get_player_leaderboard [1, 2, 3]

    assert_empty(r)
  end

  private

  def service
    StatisticsServices::PlayerStatistics.new
  end
end
