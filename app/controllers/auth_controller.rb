class AuthController < ApplicationController
  def osu
    auth_request = OsuAuthRequest.find_by_nonce(params.state)

    return if auth_request.nil?

    osu_user = auth_request.process_code_response(params.code)
    auth_request.player.complete_osu_verification(params.state, osu_user)
  end
end
