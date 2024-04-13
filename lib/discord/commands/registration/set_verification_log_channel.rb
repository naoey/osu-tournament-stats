require 'discordrb'

require_relative '../command_base'

class SetVerificationLogChannel < CommandBase
  protected

  def required_options
    [
      ['-c TEXT', '--channel', 'The ID of the channel to use for registering new users.']
    ]
  end

  def requires_admin?
    true
  end

  def make_response
    Rails.logger.tagged(self.class.name) do
      Rails.logger.debug("New set channel request #{@event.message.author.defined_permission?(:administrator)}")
    end

    return @event.respond('Channel ID is required!') if @options[:channel].nil?

    return @event.respond('Channel does not exist or bot does not have access') unless @event.message.server.text_channels.any? do |c|
      c.id.to_s == @options[:channel]
    end

    server = DiscordServer.create_or_find_by(discord_id: @event.message.server.id)

    server.verification_log_channel_id = @options[:channel]
    server.save!

    @event.respond('Updated log channel!')
  end
end
