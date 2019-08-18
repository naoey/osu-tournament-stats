require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get matches_show_url
    assert_response :success
  end

  test "should get add" do
    get matches_add_url
    assert_response :success
  end

  test "should get delete" do
    get matches_delete_url
    assert_response :success
  end

end
