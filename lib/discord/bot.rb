require 'discordrb'
require 'singleton'
require 'markdown-tables'

module Discord
  class OsuDiscordBot
    include Singleton

    def initialize!
      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Initialising Discord bot...' }

      @client = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_BOT_TOKEN'], prefix: ENV['DISCORD_BOT_PREFIX']

      @client.command :setuser, &method(:set_user)
      @client.command %i[match_performance p], &method(:match_performance)
      @client.command %i[:score_leaderboard, slb], &method(:score_leaderboard)

      @client.run true

      Rails.logger.tagged(self.class.name) { Rails.logger.info 'Osu Discord bot is running'}
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
          url: 'https://oiwt19.naoey.pw/',
          fields: stats
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

    def score_leaderboard(event, *args)
      begin
        scores = MatchScore
          .joins(:player)
          .select('players.name as player_name, AVG(match_scores.score) AS score, ROUND(AVG(match_scores.accuracy) * 100, 2) AS average_acc, COUNT(*) as maps_played')
          .group('match_scores.player_id')
          .order('AVG(match_scores.score) DESC')
          .limit(10)

        labels = ['Player', 'Average score ▼', 'Average accuracy', 'Maps played']
        data = scores.map do |s|
          [s['player_name'], s['score'], "#{s['average_acc']}%", s['maps_played']]
        end

        "```#{MarkdownTables.plain_text(MarkdownTables.make_table(labels, data, is_rows: true))}```"
      rescue StandardError => e
        Rails.logger.tagged(self.class.name) { Rails.logger.error e }
        'Error retrieving stats'
      end
    end

    def player_statistics_service
      StatisticsServices::PlayerStatistics_Legacy.new
    end
  end
end
