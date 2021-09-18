require 'discordrb'

require_relative '../command_base'

class SetChannel < CommandBase
  protected def required_options
    [
      ['-c TEXT', '--channel', 'The ID of the channel to use for registering new users.']
    ]
  end


end
