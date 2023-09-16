class AuthController < ApplicationController
  def osu
    auth_request = OsuAuthRequest.find_by_nonce(params[:state])

    return if auth_request.nil?

    begin
      Sentry.add_breadcrumb(Sentry::Breadcrumb.new(
        category: 'auth_controller',
        type: 'debug',
        message: 'Began osu! verification handling',
        level: 'info',
        data: { auth_request: auth_request.as_json }
      ))

      osu_user = auth_request.process_code_response(params[:code])

      Sentry.add_breadcrumb(Sentry::Breadcrumb.new(
        category: 'auth_controller',
        type: 'debug',
        message: 'Successfully retrieved user JSON from osu! API',
        level: 'info',
        data: { osu_user: osu_user }
      ))

      player = Player.find_by(osu_id: osu_user['id'])

      if player.nil?
        # No existing player with this osu_id, just complete verification ez
        auth_request.player.complete_osu_verification(params[:state], osu_user)

        return render plain: 'Verification successful. Contact the Discord server administrators if you still do not have access.',
          status: :ok
      end

      if player.discord_id.nil?
        Sentry.add_breadcrumb(Sentry::Breadcrumb.new(
          category: 'auth_controller',
          type: 'debug',
          message: "Existing player found with osu_id #{osu_user['id']}, but without a linked discord ID",
          level: 'info',
          data: { existing_player: player.as_json, transient_player: auth_request.player.as_json }
        ))
        # If a player was found with this osu! ID but whose discord ID is empty, then the osu! user was likely already added earlier
        # through a match import. Link this authorising discord user to that existing player and delete the new user created by
        # the discord command.
        transient_player = auth_request.player

        player.discord_id = transient_player.discord_id

        # Find and update all foreign key dependencies on this temporary player
        OsuAuthRequest.where(player_id: transient_player.id).update_all(player_id: player.id)
        DiscordExp.where(player_id: transient_player.id).update_all(player_id: player.id)

        transient_player.destroy!
        player.save!
      elsif !player.discord_id.nil? && player.discord_id != auth_request.player.discord_id
        # Check if the original player was banned, and in the case of a hard ban trigger a separate event so the alt is banned too

        if player.ban_status == Player.ban_statuses[:hard]
          ActiveSupport::Notifications.instrument 'player.banned_discord_verify', { auth_request: auth_request, player: player }

          return render plain: 'Verification failed. This osu! account is banned on the server.',
                        status: :ok
        end

        # If a player was found with this osu! ID that already has a discord ID linked, then this is an alt discord and shouldn't
        # be allowed to register.

        ActiveSupport::Notifications.instrument 'player.alt_discord_verify', { auth_request: auth_request, player: player }

        return render plain: 'Verification failed. This osu! account is already linked to another Discord ID. Contact the server admins if you have a valid reason for using a new Discord account.',
                      status: :ok
      end

      auth_request.player.complete_osu_verification(params[:state], osu_user)

      return render plain: 'Verification successful. Contact the Discord server administrators if you still do not have access.',
        status: :ok
    rescue OsuAuthErrors::TimeoutError => e
      render plain: e.message, status: :bad_request
    rescue OsuAuthErrors::OsuAuthError => e
      logger.error(e)
      Sentry.capture_exception(e)

      render plain: e.message, status: :bad_request
    rescue StandardError => e
      logger.error(e)
      Sentry.capture_exception(e)

      render plain: 'An unknown error occurred', status: :internal_server_error
    end
  end
end
