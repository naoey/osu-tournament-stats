require 'discordrb'

require_relative '../command_base'

class Unregister < CommandBase
  protected

  def requires_admin
    true
  end

  def required_options
    [
      ['-i TEXT', '--osu_id', 'The osu! ID of the player to disassociate from their Discord ID.']
    ]
  end

  def make_response
    osu_id = @options[:osu_id]

    if osu_id.nil? && @event.message.mentions.length == 0
      return @event.respond('No user specified to unregister')
    end

    if osu_id.nil? && @event.message.mentions.length > 0
      member = @server[:discordrb_server].member(@event.message.mentions.first.id)
    end

    player = osu_id.nil? ? Player.find_by(discord_id: member.id) : Player.find_by(osu_id: osu_id.to_i)
    
    if player.nil? || player.discord_id.nil?
      return @event.respond('osu! user has not registered a Discord ID.')
    end

    if !player.osu_verified || player.osu_id.nil?
      return @event.respond('User has not registered an osu! account.')
    end

    member ||= @server[:discordrb_server].member(player.discord_id)

    ActiveRecord::Base.transaction do
      player.discord_id = nil
      player.osu_verified = false

      begin
        player.save!

        puts player.errors.full_messages

        if @server[:db_server].verified_role_id.nil?
          return @event.respond("Successfully unregistered #{player.name}, but the server does not have a verified role ID configured; no roles were modified.")
        end

        if !member.nil? && member.role?(@server[:db_server].verified_role_id)
          member.remove_role(
            @server[:db_server].verified_role_id,
            "Unregister invoked by #{@event.message.author.name} (#{@event.message.author.id})",
          )
        end

        @event.respond("Successfully unregistered #{player.name}")
      rescue StandardError => e
        Rails.logger.error(e)
        Sentry.capture_exception(e)
      end
    end
  end
end

