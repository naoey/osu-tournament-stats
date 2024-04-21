require "discordrb"
require "singleton"
require "markdown-tables"
require "optparse"

require_relative "./modules/leaderboard_commands"
require_relative "./modules/match_commands"
require_relative "./modules/registration_commands"
require_relative "./modules/exp_commands"
require_relative "../../app/helpers/discord_helper"

EMBED_GREEN = 3_066_993
EMBED_RED = 15_158_332
EMBED_PURPLE = 10_181_046

module Discord
  class OsuDiscordBot
    include Singleton

    attr_reader :client

    def initialize!
      Rails.logger.tagged(self.class.name) { Rails.logger.info "Initialising Discord bot..." }

      @client = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_BOT_TOKEN"], prefix: ENV["DISCORD_BOT_PREFIX"]

      @client.command %i[match_performance p], &method(:match_performance)

      @client.message &method(:message)
      @client.member_join &method(:member_join)
      @client.ready &method(:ready)

      @client.include! LeaderboardCommands
      @client.include! MatchCommands

      # todo: need to move all these registration steps into a different script since they need to be run only on change
      # doesn't have to run on every startup
      RegistrationCommands.init(@client)
      ExpCommands.init(@client)

      @client.run true

      ActiveSupport::Notifications.subscribe("player.discord_linked") do |_name, _started, _finished, _unique_id, data|
        osu_verification_completed(data)
      end

      Rails.logger.tagged(self.class.name) { Rails.logger.info "Osu Discord bot is running" }
    end

    def close!
      return if @client.nil?

      @client&.stop
      @client = nil

      Rails.logger.tagged(self.class.name) { Rails.logger.info "Osu Discord bot has stopped" }
    end

    private

    def match_performance(event, *args)
      begin
        player = (args.empty? ? Player.find_by_discord_id(event.user.id) : Player.find_by_name(args.join(" ")))

        return "No such player found" if player.nil?

        stats = player_statistics_service.get_player_stats(player)

        return "No stats for #{player.name}" if stats.empty?

        embed = {
          title: "Stats for #{player.name}",
          color: 0x4287f5,
          type: "rich",
          url: "https://osu.naoey.pw/",
          fields:
            stats
              .except(:player)
              .map do |k, v|
                {
                  name: "**#{k.to_s.humanize}**",
                  inline: true,
                  value:
                    if k == :best_accuracy
                      v[:accuracy]
                    elsif v.is_a?(Array)
                      v.length
                    else
                      v
                    end.to_s
                }
              end
        }

        event.respond("", false, embed)

        nil
      rescue StandardError => e
        Rails.logger.tagged(self.class.name) { Rails.logger.error e }
        "Error retrieving stats"
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
        embed.description = "Alt verification attempt"
        embed.fields = [
          Discordrb::Webhooks::EmbedField.new(name: "New user", value: "<@#{auth_request.player.discord_id}>"),
          Discordrb::Webhooks::EmbedField.new(name: "Original user", value: "<@#{original_player.discord_id}>")
        ]
      end
    end

    def osu_verification_banned(auth_request)
      server = @client.server(auth_request.discord_server.discord_id)

      get_server_log_channel(auth_request.discord_server, server)&.send_embed do |embed|
        embed.title = auth_request.player.name
        embed.url = "https://osu.ppy.sh/users/#{auth_request.player.osu_id}"
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{auth_request.player.osu_id}")
        embed.color = EMBED_RED
        embed.description = "Banned account verification"
        embed.fields = [Discordrb::Webhooks::EmbedField.new(name: "New user", value: "<@#{auth_request.player.discord_id}>")]
      end
    end

    def osu_verification_completed(data)
      servers = DiscordServer.where.not(verification_log_channel_id: nil)

      player = data[:player]

      servers.each do |server|
        guild = @client.server(server.discord_id)
        member = @client.member(server.discord_id, player.discord.uid)

        next if guild.nil? || member.nil? # Bot probably removed from server

        unless server.verified_role_id.nil?
          member.add_role(server.verified_role_id, "osu! verification completed with ID #{player.osu.uid}")
          # member.add_role(server.guest_role_id, "osu! flag is #{player.osu['country']}") if !player.osu.nil? && player.osu['country'] != 'IN'
          member.set_nick(player.osu.uname, "osu! user #{player.osu.uname} linked")
        end

        @client
          .channel(server.verification_log_channel_id, guild)
          .send_embed do |embed|
            embed.title = player.name
            embed.url = "https://osu.ppy.sh/users/#{player.osu.uid}"
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{player.osu.uid}")
            embed.color = EMBED_GREEN
            embed.description = "Verification completed"
            embed.fields = [Discordrb::Webhooks::EmbedField.new(name: "Discord user", value: member.mention || "<User not in server>")]
          end
      end
    end

    # Event handling

    def ready(event)
      Rails.cache.write("discord_bot/servers", DiscordServer.all.as_json)
    end

    def message(event)
      return if event.message.server.nil? || event.message.author.bot_account

      author_id = event.message.author.id
      server_id = event.message.server.id
      last_spoke_cache_key = "discord_bot/last_spoke/#{server_id}_#{author_id}"

      server = Rails.cache.read("discord_bot/servers").find { |s| s["discord_id"] == server_id }

      return if server.nil? || !server["exp_enabled"]

      last_spoke = Rails.cache.read(last_spoke_cache_key)

      begin
        if Rails.env.production? && !last_spoke.nil? && (Time.now - last_spoke) < 60.seconds
          Rails.logger.info("discord user #{author_id} has recently cached last spoke; skipping update")

          return
        end

        Rails.cache.write(last_spoke_cache_key, Time.now)

        player = Player.joins(:identities).find_by(identities: { provider: :discord, uid: author_id })

        # Not giving any exp to users whose Discords aren't linked
        return if player.nil?

        exp = player.discord_exp.find_by(discord_server_id: server["id"])

        exp = DiscordExp.create(player: player, discord_server_id: server["id"], detailed_exp: DiscordHelper::INITIAL_EXP) if exp.nil?

        exp.add_exp()

        Rails.cache.write(last_spoke_cache_key, exp.updated_at)

        roles = exp.get_role_ids()

        current_roles = event.message.author.roles.map { |r| r.id }
        required_roles = roles.map { |r| r[1] }
        delta_roles = required_roles - current_roles

        delta_roles.each do |r|
          t = roles.find { |rl| rl[1] == r }
          Rails.logger.info("adding role #{r} for user #{author_id} for threshold #{t}")
          event.message.author.add_role(r, "Exp threshold #{t} reached with #{exp.detailed_exp}")
        end
      rescue RuntimeError => e
        Rails.logger.error("failed to process message updates for #{author_id}")
        Rails.logger.error(e.message)
        Rails.logger.error(e.backtrace.join("\r\n"))
      end
    end

    def member_join(event)
      player = Player.joins(:identities).find_by(identities: { provider: :discord, uid: event.user.id })
      server = DiscordServer.find_by(discord_id: event.server.id)

      if player.nil?
        player =
          Player.create(
            name: DiscordHelper.sanitise_username(event.user.username),
            identities: [{ provider: :discord, uid: event.user.id, raw: {}, uname: event.user.username }]
          )
      end

      player.discord_exp.find_or_create_by(discord_server: server)
    end
  end
end
