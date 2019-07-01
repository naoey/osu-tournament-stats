class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }, prepend: true

  private

  def after_sign_in_path_for(resource)
    session["player_return_to"] || root_path
  end
end
