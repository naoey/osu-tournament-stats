require 'discordrb'

module Discord
  class OsuDiscordBot
    def initialize
      Rails.logger.tagged('Discord') { Rails.logger.info 'Initialising Discord bot...' }

      @client = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_BOT_TOKEN'], prefix: '>'

      @client.command :hello do |event, _args|
        "Hi, #{event.user.name}"
      end

      @client.command :setuser, &method(:set_user)
      @client.command %i[performance p], &method(:match_performance)

      @client.run true
    end

    def close
      @client.stop
    end

    private

    def set_user(event, *args)
      begin
        name = args.join(' ')

        player = MatchServices::OsuApiParser.new.get_or_load_player(args.join(' '))

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
          fields: StatisticsServices::PlayerStatisticsService.new.get_player_stats(player)
            .except(:player)
            .map { |k, v| { name: "**#{k.to_s.humanize}**", value: "#{v}#{k.to_s.include?('accuracy') ? '%' : ''}", inline: true } },
        }

        event.respond('', false, embed)

        nil
      rescue StandardError => e
        Rails.logger.error e
        'Error retrieving stats'
      end
    end
  end
end
