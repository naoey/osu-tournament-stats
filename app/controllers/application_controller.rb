class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }, prepend: true
end
