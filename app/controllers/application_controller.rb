class ApplicationController < ActionController::Base
  private

  def after_sign_in_path_for(resource)
    session["player_return_to"] || root_path
  end
end
