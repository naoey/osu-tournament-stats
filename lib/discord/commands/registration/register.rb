require 'discordrb'

require_relative '../command_base'

class Register < CommandBase
  protected

  def make_response
    return if @server.registration_channel_id.nil? || @server.registration_channel_id != @event.message.channel.id

    discord_auth = PlayerAuth.find_by(uid: @event.message.author.id, provider: :discord)
    osu_auth = discord_auth.nil? ? nil : discord_auth.player.identities.find_by(provider: :osu)

    if osu_auth
      if osu_auth.player.ban_status == Player.ban_statuses[:none]
        # This osu! account is already linked to a Discord account, provide role and finish registration
        @event.message.author.add_role(@server.verified_role_id)
        @event.respond("Verification completed #{mention_invoker}!")
      elsif osu_auth.player.ban_status == Player.ban_statuses[:soft]
        @event.message.author.pm(
          "You are soft banned on #{@server[:discordrb_server].name}, which means you cannot get the \"member\" role but you may access roles from #self-assign-roles"
        )
      end

      return
    end

    # manually extracting probably useful values since to_json runs into a stack too deep error
    link = Player.get_osu_verification_link({
      username: @event.message.author.global_name,
      id: @event.message.author.id,
      joined_at: @event.message.author.joined_at,
      bot_account: @event.message.author.bot_account,
      discriminator: @event.message.author.discriminator,
      avatar_id: @event.message.author.avatar_id,
      public_flags: @event.message.author.public_flags,
    }.stringify_keys)

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
      Rails.logger.tagged(self.class.name) { Rails.logger.error("Failed to execute register command\n#{e.backtrace}") }

      @event.respond(
        "#{mention_invoker} something went wrong, contact the administrators to complete your verification."
      )
    end
  end
end
