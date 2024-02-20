require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Osu < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "osu"

      option :client_options, {
        :site => "https://osu.ppy.sh",
        :authorize_url => "/oauth/authorize",
        :token_url => "/oauth/token"
      }

      option :token_params, {
        client_id: ENV.fetch('OSU_CLIENT_ID'),
        client_secret: ENV.fetch('OSU_CLIENT_SECRET'),
        headers: {
          Accept: 'application/json',
        }
      }

      uid{ raw_info['id'] }

      info do
        {
          :name => raw_info['username'],
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/me').parsed
      end
    end
  end
end
