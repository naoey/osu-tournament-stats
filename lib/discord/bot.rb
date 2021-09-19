require 'discordrb'
require 'singleton'
require 'markdown-tables'
require 'optparse'

require_relative './modules/leaderboard_commands'
require_relative './modules/match_commands'
require_relative './modules/registration_commands'

EMBED_GREEN = 3_066_993
EMBED_RED = 15_158_332

module Discord
  class OsuDiscordBot
    include Singleton

    attr_reader :client

    def initialize!
      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Initialising Discord bot...' }

      @client = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_BOT_TOKEN'], prefix: ENV['DISCORD_BOT_PREFIX']

      @client.command :setuser, &method(:set_user)
      @client.command %i[match_performance p], &method(:match_performance)

      @client.include! LeaderboardCommands
      @client.include! MatchCommands
      @client.include! RegistrationCommands

      @client.run true

      ActiveSupport::Notifications.subscribe('player.osu_verified') do |_name, _started, _finished, _unique_id, data|
        osu_verification_completed(data[:auth_request])
      end

      ActiveSupport::Notifications.subscribe('player.alt_discord_verify') do |_name, _started, _finished, _unique_id, data|
        osu_verification_alt(data[:auth_request], data[:player])
      end

      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Osu Discord bot is running' }
    end

    def close!
      return if @client.nil?

      @client&.stop
      @client = nil

      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Osu Discord bot has stopped' }
    end

    private

    def set_user(event, *args)
      begin
        name = args.join(' ')

        player = ApiServices::OsuApi.new.get_or_load_player(args.join(' '))

        return "Failed find player #{name}!" if player.nil?

        player.discord_id = event.user.id
        player.save!

        "Registered #{event.user.mention} as #{player.name}"
      rescue StandardError
        'An error occurred!'
      end
    end

    def match_performance(event, *args)
      begin
        player = if args.empty?
                   Player.find_by_discord_id(event.user.id)
                 else
                   Player.find_by_name(args.join(' '))
                 end

        return 'No such player found' if player.nil?

        stats = player_statistics_service.get_player_stats(player)

        return "No stats for #{player.name}" if stats.empty?

        embed = {
          title: "Stats for #{player.name}",
          color: 0x4287f5,
          type: 'rich',
          url: 'https://osu.naoey.pw/',
          fields: stats
            .except(:player)
            .map do |k, v|
                    {
                      name: "**#{k.to_s.humanize}**",
                      inline: true,
                      value: if k == :best_accuracy
                               v[:accuracy]
                             elsif v.is_a?(Array)
                               v.length
                             else
                               v
                             end.to_s,
                    }
                  end,
        }

        event.respond('', false, embed)

        nil
      rescue StandardError => e
        Rails.logger.tagged(self.class.name) { Rails.logger.error e }
        'Error retrieving stats'
      end
    end

    def player_statistics_service
      StatisticsServices::PlayerStatistics_Legacy.new
    end

    def osu_verification_alt(auth_request, original_player)
      server = @client.server(auth_request.discord_server.discord_id)

      get_server_log_channel(auth_request.discord_server, server)&.send_embed do |embed|
        embed.title = original_player.name
        embed.url = "https://osu.ppy.sh/users/#{original_player.osu_id}"
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{original_player.osu_id}")
        embed.color = EMBED_RED
        embed.description = 'Alt verification attempt'
        embed.fields = [
          Discordrb::Webhooks::EmbedField.new(name: 'New user', value: "<@#{auth_request.player.discord_id}>"),
          Discordrb::Webhooks::EmbedField.new(name: 'Original user', value: "<@#{original_player.discord_id}>")
        ]
      end
    end

    def osu_verification_completed(auth_request)
      Rails.logger.tagged(self.class.name) { Rails.logger.info("Completing osu verification for user #{auth_request.player}.") }

      server = @client.server(auth_request.discord_server.discord_id)

      if server.nil?
        Rails.logger.tagged(self.class.name) do
          Rails.logger.error(
            "Error completing verification for #{auth_request.player}. Server #{auth_request.discord_server} not found."
          )
        end

        return
      end

      member = @client.member(server.id, auth_request.player.discord_id)

      if member.nil?
        Rails.logger.tagged(self.class.name) do
          Rails.logger.error(
            "Error completing verification for #{auth_request.player}. Member #{auth_request.player} not found."
          )
        end

        return
      end

      member.add_role(auth_request.discord_server.verified_role_id, 'osu! verification completed')

      get_server_log_channel(auth_request.discord_server, server)&.send_embed do |embed|
        embed.title = auth_request.player.name
        embed.url = "https://osu.ppy.sh/users/#{auth_request.player.osu_id}"
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{auth_request.player.osu_id}")
        embed.color = EMBED_GREEN
        embed.description = 'Verification completed'
        embed.fields = [
          Discordrb::Webhooks::EmbedField.new(name: 'Discord user', value: member.mention || '<No user>')
        ]
      end
    end

    def get_server_log_channel(server, discordrb_server)
      return nil if server.verification_log_channel_id.nil?

      @client.channel(server.verification_log_channel_id, discordrb_server)
    end
  end
end
