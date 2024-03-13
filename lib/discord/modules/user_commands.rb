require 'discordrb'

require_relative '../commands/registration/set_channel'
require_relative '../commands/registration/set_verification_log_channel'
require_relative '../commands/registration/set_verified_role'
require_relative '../commands/registration/register'
require_relative '../commands/registration/unregister'
require_relative '../commands/registration/whois'
require_relative '../commands/registration/ban'
require_relative '../commands/registration/unban'

module UserCommands
  def self.register(client)
    client.register_application_command(:user, 'Manage server membership') do |cmd|
      cmd.subcommand(:unregister, 'Unlink osu! and Discord accounts') do |sub|
        sub.options([{ name: 'user', description: 'The user to unregister', type: 6, required: true }])
      end
    end

    client.application_command(:register) do |event, *args|
      Register.new(event, *args).response
    end

    client.application_command(:register).subcommand(:unregister) do |event, *args|
      Unregister.new(event, *args).response
    end

    client.application_command(:whois) do |event, *args|
      Whois.new(event, *args).response
    end

    client.application_command(:ban) do |event, *args|
      Ban.new(event, *args).response
    end

    client.application_command(:unban) do |event, *args|
      Unban.new(event, *args).response
    end
  end
end
