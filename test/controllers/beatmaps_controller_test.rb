require 'test_helper'

class BeatmapsControllerTest < ActionDispatch::IntegrationTest
  test "should get get" do
    get beatmaps_get_url
    assert_response :success
  end

end
