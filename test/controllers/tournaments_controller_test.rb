require 'test_helper'

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get tournaments_show_url
    assert_response :success
  end

  test "should get delete" do
    get tournaments_delete_url
    assert_response :success
  end

  test "should get edit" do
    get tournaments_edit_url
    assert_response :success
  end

end
