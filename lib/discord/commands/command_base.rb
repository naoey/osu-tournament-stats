require 'optparse';

class CommandBase
  def initialize(event, *args)
    @event = event
    @bot_args = args

    @options = {}

    OptionParser.new do |opts|
      required_options.each do |opt|
        opts.on(*opt)
      end

      opts.on('-h', '--help', 'Prints this help message') do
        @help_message = opts
      end
    end.parse!(event.message.content.split(' '), into: @options)
  end

  def response
    return "```#{@help_message}```" if @options[:help]

    make_response
  end

  protected

  def make_response
    nil
  end

  def required_options
    []
  end
end
