class AuthController < ApplicationController
  def osu
    auth_request = OsuAuthRequest.find_by_nonce(params[:state])

    return if auth_request.nil?

    begin
      osu_user = auth_request.process_code_response(params[:code])

      player = Player.find_by(osu_id: osu_user['id'])

      if !player.nil? && player != auth_request.player
        # If a player was found with this osu! ID but is not the player who invoked this auth request, it's like a player created
        # through an osu! match import and is not linked to this Discord user. Link them here and delete the new user that was created
        # by the Discord command if any
        dummy_player = auth_request.player

        player.discord_id = dummy_player.discord_id
        auth_request.player = player

        player.save!
        auth_request.save!
        dummy_player.destroy!
      end

      auth_request.player.complete_osu_verification(params[:state], osu_user)

      render json: { message: 'Verification successful. Contact the Discord server administrators if you still do not have access.' },
             status: :ok
    rescue OsuAuthErrors::TimeoutError => e
      render json: { message: e.message }, status: :bad_request
    rescue OsuAuthErrors::OsuAuthError => e
      render json: { message: e.message }, status: :bad_request
    rescue StandardError => e
      logger.error(e)
      render json: { message: 'An unknown error occurred' }, status: :internal_server_error
    end
  end
end
