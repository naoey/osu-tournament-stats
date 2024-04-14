require 'discordrb'

require_relative '../command_base'

class Unregister < CommandBase
  def self.required_options
    [
      [[6, 'user', 'The user to unregister. Has higher precedence than osu_id.'], {}],
      [[10, 'osu_id', 'The osu! ID to unregister. Can be used when the linked Discord account is not in the server.'], {}]
    ]
  end

  protected

  def requires_admin?
    true
  end

  def handle_response
    return @event.respond(content: 'Verified role ID is not configured properly', ephemeral: true) if @server.verified_role_id.nil?

    user_id = @event.options['user']&.to_i
    osu_id = @event.options['osu_id']&.to_i

    if user_id.nil? && osu_id.nil?
      return @event.respond(content: 'At least one of user or osu_id options is required', ephemeral: true)
    end

    player = if user_id
      PlayerAuth.find_by(provider: :discord, uid: user_id)&.player
    else
      PlayerAuth.find_by(provider: :osu, uid: osu_id)&.player
    end

    if player.nil? || player.discord.nil? || player.osu.nil?
      return @event.respond(
        content: 'Unable to find a registered user with the given options',
        ephemeral: true
      )
    end

    osu_account_name = player.identities.find_by(provider: :osu).uname
    member = @event.server.member(player.discord.uid)
    player.remove_additional_account(:discord)
    member&.remove_role(@server.verified_role_id)

    @event.respond(content: "Unlinked osu! user #{osu_account_name} from #{member&.name || 'unknown user'}")
  end
end
