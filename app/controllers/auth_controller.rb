class AuthController < ApplicationController
  def osu
    auth_request = OsuAuthRequest.find_by_nonce(params[:state])

    return if auth_request.nil?

    begin
      osu_user = auth_request.process_code_response(params[:code])
      auth_request.player.complete_osu_verification(params[:state], osu_user)
    rescue OsuAuthErrors::TimeoutError => e
      respond_to do |format|
        format.json { render json: { 'message': e.message }, status: :bad_request }
      end
    rescue Error => e
      logger.error(e)

      respond_to do |format|
        format.json { render json: { 'message': 'An unknown error occurred' }, status: :internal_server_error }
      end
    end

  end
end
