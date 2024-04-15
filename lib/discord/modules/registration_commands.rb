require "discordrb"

require_relative "../commands/registration/set_verification_log_channel"
require_relative "../commands/registration/set_verified_role"
require_relative "../commands/registration/register"
require_relative "../commands/registration/unregister"
require_relative "../commands/registration/whois"
require_relative "../commands/registration/ban"
require_relative "../commands/registration/unban"

module RegistrationCommands
  def self.init(bot)
    bot.register_application_command(:register, "Link your osu! ID with your Discord ID")
    bot.register_application_command(:unregister, "Unlink a user from a Discord ID (admin only)") do |cmd|
      Unregister.required_options.each { |o, k| cmd.option(*o, **k) }
    end
    bot.register_application_command(:who, "Get info on a server member") do |cmd|
      Whois.required_options.each { |o, k| cmd.option(*o, **k) }
    end

    bot.application_command(:register) { |event| Register.new(bot, event).respond }

    bot.application_command(:unregister) { |event| Unregister.new(bot, event).respond }

    bot.application_command(:who) { |event| Whois.new(bot, event).respond }
  end
end
