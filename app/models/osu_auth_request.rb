require 'net/https'

OSU_AUTH_URL = 'https://osu.ppy.sh/oauth/authorize'.freeze
OSU_TOKEN_URL = 'https://osu.ppy.sh/oauth/token'.freeze
OSU_SELF_REQUEST_URL = 'https://osu.ppy.sh/api/v2/me'.freeze

class OsuAuthRequest < ApplicationRecord
  before_create { self.nonce = SecureRandom.uuid }

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
    params = {
      'client_id': ENV.fetch('OSU_CLIENT_ID'),
      'client_secret': ENV.fetch('OSU_CLIENT_SECRET'),
      'code': code,
      'grant_type': 'authorization_code',
    }

    token_response = Net::HTTP.post(
      URI(OSU_TOKEN_URL),
      params,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    )

    Net::HTTP.post(
      URI(OSU_SELF_REQUEST_URL),
      {},
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': "Bearer #{token_response['access_token']}"
    )
  end
end
