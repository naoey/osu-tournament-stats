require 'discordrb'

require_relative '../command_base'

class Unregister < CommandBase
  protected

  def requires_admin
    true
  end

  def make_response
    if @event.message.mentions.length == 0
      return @event.respond('No user specified to unregister')
    end

    if @event.message.mentions.length > 1
      return @event.respond('Mention a single user to unregister')
    end

    mentioned_member = @event.message.server.member(@event.message.mentions.first.id)

    return @event.respond('Mentioned user is not in the server') if mentioned_member.nil?

    player = Player.find_by(discord_id: mentioned_member.id)
    server = DiscordServer.find_by(discord_id: @event.message.server.id)

    if player.nil?
      return @event.respond("User #{mentioned_member.name} is not registered")
    end

    ActiveRecord::Base.transaction do
      player.discord_id = nil
      player.osu_verified = false

      player.save!

      if mentioned_member.role?(server.verified_role_id)
        mentioned_member.remove_role(server.verified_role_id, "Unregister invoked by #{@event.message.author.name} (#{@event.message.author.id})")
      end

      @event.respond("Succesfully unregistered #{mentioned_member.name}")
    end
  end
end

