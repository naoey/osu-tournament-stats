class AuthController < ApplicationController
  def osu
    auth_request = OsuAuthRequest.find_by_nonce(params[:state])

    return if auth_request.nil?

    begin
      osu_user = auth_request.process_code_response(params[:code])

      player = Player.find_by(osu_id: osu_user['id'])

      if !player.nil? && player.discord_id.nil?
        # If a player was found with this osu! ID but whose discord ID is empty, then the osu! user was likely already added earlier
        # through a match import. Link this authorising discord user to that existing player and delete the new user created by
        # the discord command.
        dummy_player = auth_request.player

        player.discord_id = dummy_player.discord_id
        auth_request.player = player

        auth_request.save!
        player.save!
        dummy_player.destroy!
      elsif !player.nil? && !player.discord_id.nil? && player.discord_id != auth_request.player.discord_id
        # If a player was found with this osu! ID but whose discord ID doens't match the existing discord ID, they are trying to verify
        # an alternate discord ID and should not be allowed.

        ActiveSupport::Notifications.instrument 'player.alt_discord_verify', { auth_request: auth_request, player: player }

        return render plain: 'Verification failed. This osu! account is already linked to another Discord ID. Contact the server admins if you have a valid reason for using a new Discord account.',
                      status: :ok
      end

      auth_request.player.complete_osu_verification(params[:state], osu_user)

      render plain: 'Verification successful. Contact the Discord server administrators if you still do not have access.',
             status: :ok
    rescue OsuAuthErrors::TimeoutError => e
      render plain: e.message, status: :bad_request
    rescue OsuAuthErrors::OsuAuthError => e
      render plain: e.message, status: :bad_request
    rescue StandardError => e
      logger.error(e)
      render plain: 'An unknown error occurred', status: :internal_server_error
    end
  end
end
