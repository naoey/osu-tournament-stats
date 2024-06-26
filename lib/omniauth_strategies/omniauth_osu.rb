require "omniauth-oauth2"
require "oauth2"
require "uri"

require_relative "../../app/helpers/auth_helper"

module OmniAuth
  module Strategies
    class Osu < OmniAuth::Strategies::OAuth2
      class OsuAccessToken < ::OAuth2::AccessToken
        def headers
          { Accept: "application/json", "Content-Type": "application/json" }.merge(super)
        end
      end

      option :name, "osu"

      option :client_options,
             {
               site: "https://osu.ppy.sh/api/v2/",
               authorize_url: "https://osu.ppy.sh/oauth/authorize",
               token_url: "https://osu.ppy.sh/oauth/token",
               access_token_class: OsuAccessToken
             }

      option :token_params,
             {
               client_id: ENV.fetch("OSU_CLIENT_ID", ""),
               client_secret: ENV.fetch("OSU_CLIENT_SECRET", ""),
               redirect_uri: ::AuthHelper.get_callback_url("osu"),
               headers: {
                 Accept: "application/json"
               }
             }

      option :token_method, :post

      uid { raw_info["id"] }

      info { raw_info.to_hash }

      extra { { "raw_info" => raw_info } }

      def raw_info
        @raw_info ||= access_token.get("me").parsed
      end
    end
  end
end
