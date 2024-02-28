class UsersController < ApplicationController
  before_action :authenticate_player!

  def show_edit_profile
    return render status: 404 if params[:id] != 'me'

    @user = current_player
    render template: 'users/show_edit_profile'
  end

  def delete_identity
    args = params.permit(:provider, :id)

    respond_to do |format|
      format.json do
        return render status: :bad_request if args[:id] != 'me'

        provider = args[:provider]
        id = current_player.identities.find_by_provider(provider)

        return render json: { error: "Provider #{provider} is not linked." }, status: :bad_request if id.nil?

        id.destroy!

        render json: current_player.identities.as_json(include: :auth_provider, except: :raw)
      end
    end
  end
end
