require "base64"

require_relative "../errors/osu_auth_errors"

class AuthController < Devise::OmniauthCallbacksController
  FLOW_CODE = { "discord_bot" => 0, "direct" => 1, "login" => 2 }.freeze

  skip_before_action :verify_authenticity_token, only: %i[osu discord]

  def osu
    @service_name = "osu!"

    begin
      auth = request.env["omniauth.auth"]
      params = Rack::Utils.parse_query(Base64.decode64(request.params["state"]))
      raw_user = auth["extra"]["raw_info"]
      player = Player.from_omniauth(auth)

      flow_code =
        if !params["f"].empty? && params["f"] == "bot" && !params["s"].empty?
          AuthController::FLOW_CODE["discord_bot"]
        elsif !player&.persisted?
          AuthController::FLOW_CODE["direct"]
        else
          AuthController::FLOW_CODE["login"]
        end

      logger.debug("⚠️began osu! OAuth handling for flow type #{flow_code}")

      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          category: "auth_controller",
          type: "debug",
          message: "began osu! OAuth callback",
          level: "info",
          data: {
            flow_code:,
            state: params,
            raw_user:
          }
        )
      )

      if flow_code.zero?
        begin
          player.complete_osu_verification_link(params["s"])
        rescue OsuAuthError::TimeoutError
          return render plain: "Timeout"
        rescue OsuAuthError::UnauthorisedError
          raise ActionController::BadRequest
        end
      else
        id = player.identities.find_by_provider("osu")

        if id.raw.nil?
          id.raw = auth.info
          logger.info("ℹ️osu! user logged in has missing raw info; capturing current raw info #{id.save}")
        end
      end

      player.avatar_url = auth.info[:avatar_url]
      player.country_code = auth.info[:country_code]
      player.name = auth.info[:username]
      player.save!

      sign_in player, event: :authentication
      redirect_to authorise_success_path(player:, code: flow_code)
    rescue StandardError => e
      logger.error("⚠️osu! OAuth handling failed")
      @oauth_error = e
      process(:failure)
    end
  end

  def discord
    @service_name = "Discord"

    begin
      auth = request.env["omniauth.auth"]
      player = nil

      begin
        player = Player.from_omniauth(auth)
      rescue ArgumentError => e
        # special handling for now since registration with discord is not allowed, create and add the new identity
        # here in the controller
        Sentry.capture_exception(e)
      end

      raw_user = auth["extra"]["raw_info"]

      logger.debug("⚠️began Discord OAuth handling")

      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          category: "auth_controller",
          type: "debug",
          message: "began Discord OAuth callback",
          level: "info",
          data: {
            raw_user:,
            player: player&.id,
            logged_in: !current_player.nil?
          }
        )
      )

      unless current_player.nil?
        # if a user is already logged in and we're here in this flow, then it's adding an additional account
        current_player.add_additional_account(auth)
        return redirect_to authorise_success_path(player: current_player, code: 3)
      end

      if player.nil?
        # This Discord ID is not linked to any Player and we don't allow creating new users with anything except
        # osu! accounts so just bail
        @error_code = 0
        return process(:failure)
      end

      id = player.identities.find_by_provider("discord")

      if id.raw.nil?
        id.raw = request.env["omniauth.auth"]["extra"]["raw_info"]
        logger.info("ℹ️osu! user logged in has missing raw info; capturing current raw info #{id.save}")
      end

      sign_in player, event: :authentication
      redirect_to authorise_success_path(player:, code: 2)
    rescue ArgumentError => e
      logger.error("⚠ Discord account is not linked to an existing account")
      @error_code = 0
      @oauth_error = e
      process(:failure)
    rescue StandardError => e
      logger.error("⚠ Discord OAuth handling failed")
      @oauth_error = e
      process(:failure)
    end
  end

  def success
    return redirect_to root_path if params[:player].nil?

    @code = params[:code].to_i
    render template: "auth/success"
  end

  def failure
    # exception retrieval copied from https://github.com/heartcombo/devise/blob/main/app/controllers/devise/omniauth_callbacks_controller.rb#L22C17-L22C120
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    exception ||= @oauth_error

    return redirect_to root_path if exception.nil?

    logger.debug(exception)
    Sentry.capture_exception(exception)

    render template: "auth/failure"
  end

  private

  def map_omniauth_state
  end
end
