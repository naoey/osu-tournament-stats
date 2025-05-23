require "discordrb"

require_relative "../command_base"

class SetVerifiedRole < CommandBase
  protected

  def required_options
    [["-r TEXT", "--role", "The ID of the role to apply to verified users."]]
  end

  def requires_admin?
    true
  end

  def make_response
    logger.debug("New set channel request #{@event.message.author.defined_permission?(:administrator)}")

    return @event.respond("Role ID is required!") if @options[:role].nil?

    return @event.respond("Role does not exist!") unless @event.message.server.roles.any? { |r| r.id.to_s == @options[:role] }

    server = DiscordServer.create_or_find_by(discord_id: @event.message.server.id)

    server.verified_role_id = @options[:role]
    server.save!

    @event.respond("Updated verified role!")
  end
end
