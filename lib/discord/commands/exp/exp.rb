require_relative '../command_base'

class Exp < CommandBase
  def self.required_options
    [
      [[6, "user", "The user to unregister. Has higher precedence than osu_id."], {}],
    ]
  end

  protected

  def handle_response
    user_option = @event.options["user"]&.to_i
    player = user_option ? Player.joins(:identities).find_by(identities: { provider: :discord, uid: user_option }) : @player
    exp = DiscordExp.find_by(player: player, discord_server: @server)

    return @event.respond(content: "User is not registered") if player.nil? || exp.nil?

    percentage = (exp.detailed_exp[0].to_f / exp.detailed_exp[1].to_f) * 100

    @event.respond(
      embeds: [
        Discordrb::Webhooks::Embed.new(
          title: player.name,
          url: "https://osu.ppy.sh/users/#{player.osu&.uid}",
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{player.osu&.uid}"),
          color: EMBED_PURPLE,
          description: "KelaBot level in #{@event.server.name}",
          fields: [
            Discordrb::Webhooks::EmbedField.new(name: "User", value: "<@#{exp.player.discord.uid}>", inline: true),
            Discordrb::Webhooks::EmbedField.new(name: "Level", value: exp.level, inline: true),
            Discordrb::Webhooks::EmbedField.new(name: "Rank", value: exp.rank.to_fs(:delimited), inline: true),
            Discordrb::Webhooks::EmbedField.new(name: "XP", value: exp.exp.to_fs(:delimited), inline: true),
            Discordrb::Webhooks::EmbedField.new(
              name: "Next Level",
              value: (exp.detailed_exp[1] - exp.detailed_exp[0]).to_fs(:delimited),
              inline: true
            ),
            Discordrb::Webhooks::EmbedField.new(name: "Messages", value: exp.message_count.to_fs(:delimited), inline: true),
            Discordrb::Webhooks::EmbedField.new(
              name: "Progress",
              value:
                (":green_square:" * (percentage / 10.0).round) + (":yellow_square:" * (10 - (percentage / 10.0).round)) +
                  " *(#{percentage.round(2)}%)*"
            )
          ],
        )
      ]
    )
  end
end
