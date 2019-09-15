require 'discordrb'
require 'singleton'

module Discord
  class OsuDiscordBot
    include Singleton

    def initialize!
      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Initialising Discord bot...' }

      @client = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_BOT_TOKEN'], prefix: '>'

      @client.command :setuser, &method(:set_user)
      @client.command %i[match_performance p], &method(:match_performance)
      @client.command %i[:match_lb, mlb], &method(:match_leaderboard)

      @client.run true

      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Osu Discord bot is running'}
    end

    def close!
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

        embed = {
          title: "Stats for #{player.name}",
          color: 0x4287f5,
          type: 'rich',
          url: 'https://oiwt19.naoey.pw/',
          fields: player_statistics_service.get_player_stats(player)
            .except(:player)
            .map { |k, v| { name: "**#{k.to_s.humanize}**", value: "#{v}#{k.to_s.include?('accuracy') ? '%' : ''}", inline: true } },
        }

        event.respond('', false, embed)

        nil
      rescue StandardError => e
        Rails.logger.tagged(self.class.name) { Rails.logger.error e }
        'Error retrieving stats'
      end
    end

    def match_leaderboard
      begin

      end
    end

    def player_statistics_service
      StatisticsServices::PlayerStatistics.new
    end
  end
end
