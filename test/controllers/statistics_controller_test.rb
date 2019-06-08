require 'test_helper'

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  test "should get show matches" do
    get statistics_matches_path
    assert_response :success
  end

  test "should get show all players" do
    get statistics_players_path
    assert_response :success
  end

end
