class UsersController < ApplicationController
  before_action :authenticate_player!

  def show_edit_profile
    return render status: 404 if params[:id] != 'me'

    @user = current_player
    render template: 'users/show_edit_profile'
  end
end
