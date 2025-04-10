require "discordrb"

require_relative "../command_base"

class Register < CommandBase
  protected

  def handle_response
    user = @event.interaction.user

    Rails.logger.debug("Began registration player={}", user)

    if @server.verified_role_id.nil?
      Rails.logger.warn("Server configuration is missing verified_role_id server={}", server)

      return @event.respond(content: "Server configuration is incorrect!")
    end

    discord_auth = PlayerAuth.find_by(uid: user.id, provider: :discord)
    osu_auth = discord_auth.nil? ? nil : discord_auth.player.identities.find_by(provider: :osu)

    if osu_auth
      if osu_auth.player.ban_status == "no_ban"
        # This osu! account is already linked to a Discord account, provide role and finish registration
        user.add_role(@server.verified_role_id)
        user.add_role(@server.guest_role_id) unless @server.guest_role_id.nil? || discord_auth.player.country_code.nil? || discord_auth.player.country_code == 'IN'
        Rails.logger.info("Granting already registered user access player={}", osu_auth.player)
        @event.respond(content: "Verification complete!", ephemeral: true)
      elsif osu_auth.player.ban_status == "soft"
        Rails.logger.info("Banned player tried to register player={}", osu_auth.player)
        user.pm(
          "You are soft banned on #{@event.server.name}, which means you cannot get the \"member\" role but you may access roles from #self-assign-roles"
        )
      end

      return
    end

    # manually extracting probably useful values since to_json runs into a stack too deep error
    link = Player.get_osu_verification_link(DiscordHelper::identity_from_user(user))

    begin
      user.pm(
        "Login with your osu! account using this link to complete verifying your Discord account in #{@event.server.name}\n\n<#{link}>"
      )

      @event.respond(
        content: "Verification started for #{user.name}. Please check your DMs to complete the verification process.",
        ephemeral: true
      )
    rescue Discordrb::Errors::NoPermission
      @event.respond(
        content:
          "KelaBot doesn't have permission to DM you. Please check that server members have permission to send you DMs in your privacy settings.",
        ephemeral: true
      )
    rescue StandardError => e
      Rails.logger.tagged(self.class.name) { Rails.logger.error("Failed to execute register command\n#{e.backtrace}") }

      @event.respond(content: "Something went wrong, contact the administrators to complete your verification.", ephemeral: true)
    end
  end
end
