require_relative "boot"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require 'action_mailbox/engine'
# require 'action_text/engine'
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

require_relative '../lib/structured_formatter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OsuTournamentStats
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.cache_store = :memory_store, { size: 64.megabytes }

    config.rails_semantic_logger.format = StructuredFormatter.new

    config.active_support.to_time_preserves_timezone = :zone

    config.after_initialize do
      # https://github.com/omniauth/omniauth/issues/872
      Hashie.logger = Logger.new(nil)

      if ENV.fetch("DISCORD_ENABLED", nil) == "1" and defined?(Rails::Server)
        require_relative "../lib/discord/bot"

        Discord::OsuDiscordBot.instance.initialize!

        at_exit { Discord::OsuDiscordBot.instance.close! }
      else
        logger.info(
          "Not starting Discord bot because it is disabled or Rails server isn't starting up",
          { discord_enabled: ENV.fetch("DISCORD_ENABLED"), rails_server: defined?(Rails::Server) }
        )
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
