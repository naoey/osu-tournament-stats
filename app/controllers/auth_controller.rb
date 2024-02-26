class AuthController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :osu

  # login_flow_type_code = {
  #   "discord_bot" => 0,
  #   "direct" => 1,
  #   "login" => 2,
  # }.freeze

  def osu
    begin
      flow_code = nil
      # todo: eventually plug in registration initiated from discord here
      discord_register_request = nil
      auth = request.env["omniauth.auth"]
      raw_user = auth["extra"]["raw_info"]
      persisted_user = Player.find_by_osu_id(raw_user['id'])

      # flow_code = login_flow_type_code['discord_bot'] unless discord_register_request.nil?
      # flow_code = login_flow_type_code['direct'] if persisted_user.nil?
      # flow_code = login_flow_type_code['login']
      # todo: why the fuck is ruby so shit at something as basic as constants
      flow_code = 0 unless discord_register_request.nil?
      flow_code = 1 if persisted_user.nil?
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
        persisted_user = Player.from_osu_omniauth(auth)
        persisted_user.discord_id = discord_register_request.discord_id
        persisted_user.save!

        sign_in persisted_user, event: :authentication
        redirect_to authorise_success_path(player: persisted_user, code: flow_code)

        ActiveSupport::Notifications.instrument(
          'player.discord_linked',
          { player: persisted_user }
        )
      elsif flow_code == 1
        persisted_user = Player.from_osu_omniauth(auth)
        persisted_user.save!

        sign_in persisted_user, event: :authentication
        redirect_to authorise_success_path(player: persisted_user, code: flow_code)
      else
        persisted_user = Player.from_osu_omniauth(auth)
        persisted_user.save!

        sign_in persisted_user, event: :authentication
        redirect_to authorise_success_path(player: persisted_user, code: flow_code)
      end
    rescue StandardError => e
      logger.error("⚠️osu! OAuth handling failed")
      Sentry.capture_exception(e)
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

    @service_name = "osu!"

    logger.debug(exception)
    Sentry.capture_exception(exception)

    render template: 'auth/failure'
  end
end
