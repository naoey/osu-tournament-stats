require 'omniauth-oauth2'
require 'oauth2'

module OmniAuth
  module Strategies
    class Osu < OmniAuth::Strategies::OAuth2
      require 'oauth2/access_token'
      class OsuAccessToken < ::OAuth2::AccessToken
        def headers
          { 'Accept': 'application/json', 'Content-Type': 'application/json' }.merge(super)
        end
      end

      option :name, "osu"

      option :client_options, {
        :site => "https://osu.ppy.sh/api/v2/",
        :authorize_url => "https://osu.ppy.sh/oauth/authorize",
        :token_url => "https://osu.ppy.sh/oauth/token",
        :access_token_class => OsuAccessToken
      }

      option :token_params, {
        client_id: ENV.fetch('OSU_CLIENT_ID'),
        client_secret: ENV.fetch('OSU_CLIENT_SECRET'),
        redirect_uri: ENV.fetch('OSU_CALLBACK_URL'),
        headers: {
          Accept: 'application/json',
        }
      }

      option :token_method, :post

      uid{ raw_info['id'] }

      info do
        raw_info.to_hash
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('me').parsed
      end
    end
  end
end
