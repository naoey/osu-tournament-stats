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
    end.parse!(event.message.content.split(' '), into: @options)
  end

  def response
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
