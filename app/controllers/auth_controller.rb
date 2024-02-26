class AuthController < Devise::OmniauthCallbacksController
  # private flow_code = {
  #   "discord_bot" => 0,
  #   "direct" => 1,
  #   "login" => 2,
  # }.freeze

  skip_before_action :verify_authenticity_token, only: %i[osu discord]

  def osu
    @service_name = "osu!"

    begin
      flow_code = nil
      # todo: eventually plug in registration initiated from discord here
      discord_register_request = nil
      auth = request.env["omniauth.auth"]
      raw_user = auth["extra"]["raw_info"]
      player = Player.from_omniauth(auth)

      # flow_code = login_flow_type_code['discord_bot'] unless discord_register_request.nil?
      # flow_code = login_flow_type_code['direct'] if player.nil?
      # flow_code = login_flow_type_code['login']
      # todo: why the fuck is ruby so shit at something as basic as constants
      flow_code = 0 unless discord_register_request.nil?
      flow_code = 1 unless player&.persisted?
      flow_code = 2

      # logger.debug("⚠️began osu! OAuth handling for flow type #{login_flow_type_code.key(flow_code)}")
      logger.debug("⚠️began osu! OAuth handling for flow type #{flow_code}")

      Sentry.add_breadcrumb(Sentry::Breadcrumb.new(
        category: 'auth_controller',
        type: 'debug',
        message: 'began osu! OAuth callback',
        level: 'info',
        data: { discord_register_request: discord_register_request, raw_user: raw_user }
      ))

      if flow_code == 0
        player.identities.build(uid: discord_register_request.discord_id)
        player.save!

        ActiveSupport::Notifications.instrument(
          'player.discord_linked',
          { player: player }
        )
      end

      id = player.identities.find_by_provider('osu')

      if id.raw.nil?
        id.raw = auth.info
        logger.info("ℹ️osu! user logged in has missing raw info; capturing current raw info #{id.save}")
      end

      player.avatar_url = auth.info[:avatar_url]
      player.country_code = auth.info[:country_code]
      player.name = auth.info[:username]

      sign_in player, event: :authentication
      redirect_to authorise_success_path(player: player, code: flow_code)
    rescue StandardError => e
      logger.error("⚠️osu! OAuth handling failed")
      @oauth_error = e
      self.process(:failure)
    end
  end

  def discord
    @service_name = "Discord"

    begin
      auth = request.env['omniauth.auth']
      player = Player.from_omniauth(auth)
      raw_user = auth["extra"]["raw_info"]

      logger.debug("⚠️began Discord OAuth handling")

      Sentry.add_breadcrumb(Sentry::Breadcrumb.new(
        category: 'auth_controller',
        type: 'debug',
        message: 'began Discord OAuth callback',
        level: 'info',
        data: { raw_user: raw_user, player: player&.id }
      ))

      if player.nil?
        # This Discord ID is not linked to any Player and we don't allow creating new users with anything except
        # osu! accounts so just bail
        @error_code = 0
        return self.process(:failure)
      end

      id = player.identities.find_by_provider('discord')

      if id.raw.nil?
        id.raw = request.env["omniauth.auth"]["extra"]["raw_info"]
        logger.info("ℹ️osu! user logged in has missing raw info; capturing current raw info #{id.save}")
      end

      sign_in player, event: :authentication
      redirect_to authorise_success_path(player: player, code: 2)
    rescue ArgumentError => e
      logger.error("⚠ Discord account is not linked to an existing account")
      @error_code = 0
      @oauth_error = e
      self.process(:failure)
    rescue StandardError => e
      logger.error("⚠ Discord OAuth handling failed")
      @oauth_error = e
      self.process(:failure)
    end
  end

  def success
    return redirect_to root_path if params[:player].nil?

    @code = params[:code].to_i
    render template: 'auth/success'
  end

  def failure
    # exception retrieval copied from https://github.com/heartcombo/devise/blob/main/app/controllers/devise/omniauth_callbacks_controller.rb#L22C17-L22C120
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    exception ||= @oauth_error

    return redirect_to root_path if exception.nil?

    logger.debug(exception)
    Sentry.capture_exception(exception)

    render template: 'auth/failure'
  end
end
