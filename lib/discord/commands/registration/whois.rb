require_relative '../command_base'

class Whois < CommandBase
  protected

  def make_response
    if @event.message.mentions.length != 1
      return @event.respond('Whois requires one mentioned user')
    end

    target = @event.message.mentions.first
    player = Player.find_by(discord_id: target.id)

    return @event.respond("User #{target.name} not found") if player.nil?
    return @event.respond("User #{target.name} not verified with osu") unless player.osu_verified

    auth_requests = player
      .osu_auth_requests
      .where(resolved: true)
      .order('updated_at DESC')

    if auth_requests.empty?
      Rails.logger.tagged(self.class.name) {
        Rails.logger.warn("Reached osu info block for player #{player.id} but user does not have any resolved auth requests")
      }
    end

    timestamp = auth_requests.first&.updated_at&.to_time&.to_i

    @event.message.channel.send_embed do |embed|
      embed.title = player.name
      embed.url = "https://osu.ppy.sh/users/#{player.osu_id}"
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://a.ppy.sh/#{player.osu_id}")
      embed.color = EMBED_GREEN
      embed.fields = [
        Discordrb::Webhooks::EmbedField.new(name: 'Discord user', value: "<@#{player.discord_id}>", inline: true),
        Discordrb::Webhooks::EmbedField.new(name: 'osu! ID', value: player.osu_id, inline: true),
        Discordrb::Webhooks::EmbedField.new(
          name: 'Verified on',
          value: timestamp.nil? ? 'Never' : "<t:#{timestamp}>"
        )
      ]
    end
  end
end
