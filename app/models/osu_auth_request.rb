require 'net/https'
require 'json'
require 'rest-client'

OSU_AUTH_URL = 'https://osu.ppy.sh/oauth/authorize'.freeze
OSU_TOKEN_URL = 'https://osu.ppy.sh/oauth/token'.freeze
OSU_SELF_REQUEST_URL = 'https://osu.ppy.sh/api/v2/me'.freeze

class OsuAuthRequest < ApplicationRecord
  before_create { self.nonce = SecureRandom.uuid }

  belongs_to :player
  belongs_to :discord_server

  def authorisation_link
    params = {
      'client_id': ENV.fetch('OSU_CLIENT_ID'),
      'redirect_uri': ENV.fetch('OSU_CALLBACK_URL'),
      'response_type': 'code',
      'scope': 'identify',
      'state': nonce,
    }

    "#{OSU_AUTH_URL}?#{params.to_query}"
  end

  def process_code_response(code)
    if created_at < 10.minutes.ago
      raise OsuAuthErrors::TimeoutError, 'Auth request timed out. Please restart the registration process.'
    end

    params = {
      'client_id': ENV.fetch('OSU_CLIENT_ID'),
      'client_secret': ENV.fetch('OSU_CLIENT_SECRET'),
      'code': code,
      'grant_type': 'authorization_code',
      'redirect_uri': ENV.fetch('OSU_CALLBACK_URL'),
    }

    begin
      token_response = RestClient.post(
        OSU_TOKEN_URL,
        params,
        { accept: :json, content_type: :json }
      )
    rescue RestClient::ExceptionWithResponse => e
      logger.error("Failed to exchange code for osu! API token for auth request #{id}. Got #{e.response.code} response #{e.response.body}")
      raise OsuAuthErrors::UnauthorisedError, 'osu! authorisation failed!'
    end

    token_json = JSON.parse(token_response.body)

    begin
      user_response = RestClient.get(
        OSU_SELF_REQUEST_URL,
        { accept: :json, content_type: :json, authorization: "Bearer #{token_json['access_token']}" }
      )
    rescue RestClient::ExceptionWithResponse => e
      logger.error("Failed to retrieve user details for auth request #{id}. Got #{e.response.code} response #{e.response.body}")
      raise OsuAuthErrors::OsuAuthError, 'Failed to retrieve user from osu! API.'
    end

    JSON.parse(user_response.body)
  end
end
