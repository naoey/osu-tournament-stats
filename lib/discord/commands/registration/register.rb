require 'discordrb'

require_relative '../command_base'

class Register < CommandBase
  protected

  def make_response
    player = Player.find_or_create_by(discord_id: @event.message.author.id)
    server = DiscordServer.find_or_create_by(discord_id: @event.message.server.id)

    return if server.registration_channel_id.nil? || server.registration_channel_id != @event.message.channel.id

    if player.osu_verified
      @event.message.author.add_role(server.verified_role_id)
      @event.respond("Verification completed #{mention_invoker}!")

      return
    end

    link = player.begin_osu_discord_verification(server)

    begin
      @event.message.author.pm(
        "Login with your osu! account using this link to complete verifying your Discord account in #{@event.message.server.name}\n\n<#{link}>"
      )

      @event.respond("Verification started for #{@event.message.author.name}. Please check your DMs to complete the verification process.")
    rescue Discordrb::Errors::NoPermission
      @event.respond(
        "#{mention_invoker} KelaBot doesn't have permission to DM you. Please check that server members have permission to send you DMs in your privacy settings."
      )
    rescue StandardError => e
      Rails.logger.tagged(self.class.name) { Rails.logger.error("Failed to execute register command\n#{e.backtrace}")}

      @event.respond(
        "#{mention_invoker} something went wrong, contact the administrators to complete your verification."
      )
    end
  end
end
