require 'discordrb'

require_relative '../commands/registration/set_channel'
require_relative '../commands/registration/set_verification_log_channel'
require_relative '../commands/registration/set_verified_role'
require_relative '../commands/registration/register'
require_relative '../commands/registration/unregister'
require_relative '../commands/registration/whois'

module RegistrationCommands
  extend Discordrb::Commands::CommandContainer

  command(:set_register_channel, aliases: [], description: 'Set channel for registration') do |event, *args|
    SetChannel.new(event, *args).response
  end

  command(:set_verification_log_channel, aliases: [],
                                         description: 'Set channel for logging successful verifications') do |event, *args|
    SetVerificationLogChannel.new(event, *args).response
  end

  command(:set_verified_role, aliases: [], description: 'Set the role to be applied to verified users') do |event, *args|
    SetVerifiedRole.new(event, *args).response
  end

  command(:register, aliases: [], description: 'Begin registration for a user') do |event, *args|
    Register.new(event, *args).response
  end

  command(:unregister, aliases: [], description: 'Unlinks Discord user from osu! user. Admin only.') do |event, *args|
    Unregister.new(event, *args).response
  end

  command(:whois, aliases: [:who], description: 'Display linked osu! profile') do |event, *args|
    Whois.new(event, *args).response
  end

  command(:ban, aliases: [], description: 'Ban a user') do |event, *args|
    Ban.new(event, *args).response
  end
end
