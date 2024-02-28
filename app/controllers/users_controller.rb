class UsersController < ApplicationController
  before_action :authenticate_player!

  respond_to :json, only: %i[delete_identity create_identity]

  def show_edit_profile
    return render status: 404 if params[:id] != 'me'

    @user = current_player
    render template: 'users/show_edit_profile'
  end

  def delete_identity
    params = params.permit(:provider)

    return render status: :bad_request if params[:id] != 'me'

    provider = params[:provider]
    id = current_player.identities.find_by_provider(provider)

    return render json: { error: "Provider #{provider} is not linked." }, status: :bad_request if id.nil?

    id.destroy!

    render json: { result: 'ok' }
  end

  def create_identity; end
end
