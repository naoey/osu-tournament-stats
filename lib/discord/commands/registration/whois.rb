require_relative "../command_base"

class Whois < CommandBase
  def self.required_options
    [
      [[6, "user", "The user whose info to show."]],
      [[10, "osu_id", "Lookup user by osu! ID. Can be used when the linked Discord account is unknown."]]
    ]
  end

  protected

  def handle_response
    player = if @event.options["user"]
      PlayerAuth.find_by(provider: :discord, uid: @event.options["user"].to_i)&.player
    elsif @event.options["osu_id"]
      PlayerAuth.find_by(provider: :osu, uid: @event.options["osu_id"].to_i)&.player
    else
      return @event.respond(content: "One of user or osu_id is required.", ephemeral: true)
    end

    return @event.respond(content: "User is not registered with KelaBot") if player.nil?
    return @event.respond(content: "User has no linked osu! ID") if player.osu.nil?

    @event.respond(
      embeds: [
        Discordrb::Webhooks::Embed.new(
          title: player.name,
          url: "https://osu.ppy.sh/users/#{player.osu.uid}",
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{player.osu.uid}"),
          color: EMBED_GREEN,
          fields: [
            Discordrb::Webhooks::EmbedField.new(
              name: "Discord user",
              value: @bot.member(@event.server.id, player.discord.uid)&.mention || "MIA",
              inline: true
            ),
            Discordrb::Webhooks::EmbedField.new(name: "osu! ID", value: player.osu.uid, inline: true),
            Discordrb::Webhooks::EmbedField.new(
              name: "Ban status",
              value: player.ban_status.to_s,
              inline: true
            ),
            Discordrb::Webhooks::EmbedField.new(name: "Ban count", value: player.ban_history.count.to_s, inline: true),
            Discordrb::Webhooks::EmbedField.new(
              name: "Country",
              value: player.country_code.nil? ? ":alien:" : ":flag_#{player.country_code.downcase}:",
              inline: true
            ),
            Discordrb::Webhooks::EmbedField.new(name: "Created on", value: "<t:#{player.created_at.to_time.to_i}>"),
            Discordrb::Webhooks::EmbedField.new(
              name: "osu! verified on",
              value: player.osu ? "<t:#{player.osu.created_at.to_time.to_i}>" : "N/A"
            )
          ]
        )
      ]
    )
  end
end
