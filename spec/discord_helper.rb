module Discord
  module Test
    class OsuDiscordTestBot
      attr_reader :client

      def self.create_test_bot
        OsuDiscordTestBot.new
      end

      def initialize!
        Rails.logger.tagged(self.class.name) { Rails.logger.info "Initialising Discord bot..." }

        @client = MockCommandBot.new

        Rails.logger.tagged(self.class.name) { Rails.logger.info "Osu Discord bot is running" }
      end
    end

    class MockCommandBot
      def register_application_command(name, description, server_id: nil, default_permission: nil, type: :chat_input)
        Rails.logger.tagged(self.class.name) { Rails.logger.info "Application command #{name} registered"}
      end

      def application_command(name, attributes = {}, &block)
        @application_commands ||= {}

        unless block
          @application_commands[name] ||= MockApplicationCommandEventHandler.new(attributes, nil)
          return @application_commands[name]
        end

        @application_commands[name] = MockApplicationCommandEventHandler.new(attributes, block)
      end
    end

    class MockApplicationCommandEventHandler
      attr_reader :attributes, :block

      def initialize(attributes, block)
        @attributes = attributes
        @block = block
      end

      def respond(*a, **k)
        Rails.logger.tagged(self.class.name) { Rails.logger.info "Event responded" }
      end
    end
  end
end
