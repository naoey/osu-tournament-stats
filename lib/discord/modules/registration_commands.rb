require 'discordrb'

require_relative '../commands/registration/set_channel'
require_relative '../commands/registration/set_verification_log_channel'
require_relative '../commands/registration/set_verified_role'
require_relative '../commands/registration/register'

module RegistrationCommands
  extend Discordrb::Commands::CommandContainer

  command(:set_register_channel, aliases: [], description: 'Set channel for registration') do |event, *args|
    SetChannel.new(event, *args).response
  end

  command(:set_verification_log_channel, aliases: [], description: 'Set channel for logging successful verifications') do |event, *args|
    SetVerificationLogChannel.new(event, *args).response
  end

  command(:set_verified_role, aliases: [], description: 'Set the role to be applied to verified users') do |event, *args|
    SetVerifiedRole.new(event, *args).response
  end

  command(:register, aliases: [], description: 'Begin registration for a user') do |event, *args|
    Register.new(event, *args).response
  end
end
