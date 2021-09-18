require 'discordrb'

require_relative '../command_base'

class Register < CommandBase
  protected

  def make_response
    player = Player.find_or_create_by(discord_id: @event.message.author.id)

    return @event.respond("Verification successful #{mention_invoker}!") if player.osu_verified

    server = DiscordServer.find_or_create_by(discord_id: @event.message.server.id)

    if server.verified_role_id.nil? || server.registration_channel_id.nil?
      return @event.respond(
        'User registration is not configured on this server. Contact the administrators to set it up!'
      )
    end

    return if server.registration_channel_id != @event.message.channel.id

    link = player.begin_osu_discord_verification(server)

    begin
      @event.message.author.pm(
        "Login with your osu! account using this link to complete verifying your Discord account in #{@event.message.server.name}\n\n<#{link}>"
      )

      @event.respond("Verification begun for #{@event.message.author.name}. Please check your DMs to complete the verification process.")
    rescue Discordrb::Errors::NoPermission
      @event.respond(
        "#{mention_invoker} KelaBot doesn't have permission to DM you. Please check that server members have permission to send you DMs in your privacy settings."
      )
    end
  end
end
