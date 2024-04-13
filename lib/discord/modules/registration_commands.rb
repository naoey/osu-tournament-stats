require 'discordrb'

require_relative '../commands/registration/set_channel'
require_relative '../commands/registration/set_verification_log_channel'
require_relative '../commands/registration/set_verified_role'
require_relative '../commands/registration/register'
require_relative '../commands/registration/unregister'
require_relative '../commands/registration/whois'
require_relative '../commands/registration/ban'
require_relative '../commands/registration/unban'

module RegistrationCommands
  def self.init(bot)
    bot.register_application_command(:register, 'Link your osu! ID with your Discord ID')
    bot.register_application_command(:unregister, 'Unlink a user from a Discord ID (admin only)') do |cmd|
      Unregister.required_options.each do |o|
        cmd.option(*o)
      end
    end

    bot.application_command(:register) do |event|
      Register.new(bot, event).respond
    end

    bot.application_command(:unregister) do |event|
      Unregister.new(bot, event).respond
    end
  end
end
