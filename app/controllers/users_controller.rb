require "base64"

class UsersController < ApplicationController
  before_action :authenticate_player!, except: %i[show_link_osu_discord]

  def show_edit_profile
    return render status: 404 if params[:id] != "me"

    @user = current_player
    render template: "users/show_edit_profile"
  end

  def show_link_osu_discord
    return ActionController::BadRequest if params[:f] != "bot" || params[:s].empty?

    begin
      discord_id, = Base64.decode64(params[:s]).split("|")
      state = Rails.cache.read("discord_bot/osu_verification_links/#{discord_id}")

      return render plain: "Timeout" if state.nil?

      @query = Base64.encode64(request.query_string)
      @username = state["user"]["username"]
    rescue StandardError
      raise ActionController::BadRequest
    end

    render template: "users/show_link_osu_discord"
  end

  def delete_identity
    args = params.permit(:provider, :id)

    respond_to do |format|
      format.json do
        return render status: :bad_request if args[:id] != "me"

        begin
          current_player.remove_additional_account(args[:provider])
        rescue ArgumentError
          return render json: { error: "Provider #{provider} is not linked." }, status: :bad_request if id.nil?
        end

        render json: current_player.identities.as_json(include: :auth_provider, except: :raw)
      end
    end
  end
end
