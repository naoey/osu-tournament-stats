require 'optparse'

class CommandBase
  def initialize(event, *args)
    @event = event
    @bot_args = args
    @server = DiscordServer.find_by_discord_id(event.message.server.id)
    @invoker = PlayerAuth.find_by(uid: event.message.author.id, provider: :discord)&.player

    @options = {}

    begin
      OptionParser.new do |opts|
        required_options.each do |opt|
          opts.on(*opt)
        end

        opts.on('-h', '--help', 'Prints this help message') do
          @help_message = opts
        end
      end.parse!(event.message.content.split(' '), into: @options)
    rescue OptionParser::MissingArgument
      @event.respond("Missing arguments")
      raise
    end
  end

  def response
    return "```#{@help_message}```" if @options[:help]

    return 'Can only be invoked by adminstrators!' if requires_admin && !invoker_admin?

    begin
      make_response
    rescue Discordrb::Errors::NoPermission
    end
  end

  protected

  def mention_invoker
    @event.message.author.mention
  end

  def requires_admin
    false
  end

  def invoker_admin?
    @event.message.author.defined_permission?(:administrator) || invoker_owner?
  end

  def invoker_owner?
    @event.message.author.owner?
  end

  def make_response
    nil
  end

  def required_options
    []
  end
end
