require 'optparse'

class CommandBase
  def initialize(bot, event, *args)
    @bot = bot
    @event = event
    @bot_args = args
    @server = DiscordServer.find_by_discord_id(event.server.id)
    @player = PlayerAuth.find_by(uid: event.interaction.user.id, provider: :discord)&.player
  end

  def respond
    @event.respond(content: 'Can only be used by staff!', ephemeral: true) if requires_admin? && !invoker_admin?

    begin
      handle_response
    rescue Discordrb::Errors::NoPermission
    end
  end

  def self.required_options
    []
  end

  protected

  def mention_invoker
    @event.interaction.user.mention
  end

  def requires_admin?
    false
  end

  def invoker_admin?
    @event.interaction.user.defined_permission?(:administrator) || invoker_owner?
  end

  def invoker_owner?
    @event.interaction.user.owner?
  end

  def handle_response
    nil
  end
end
