require 'discordrb'

require_relative '../command_base'

class Ban < CommandBase
  protected

  def required_options
    [
      ['-t TEXT', '--type', 'Ban type. One of [soft, hard]. Default is hard ban.'],
      ['-r TEXT', '--reason', 'Reason for ban.']
    ]
  end

  def requires_admin
    true
  end

  def make_response
    mentioned_member = @server[:discordrb_server].member(@event.message.mentions.first&.id)

    return @event.respond("Unable to find user #{mentioned_member.name} in the server") if mentioned_member.nil?
    return @event.respond("#{mentioned_member.name} is already banned") unless BannedUser.find_by_discord_id(mentioned_member.id).nil?

    ban_type = @options[:type]&.to_sym || BannedUser.ban_types[:hard]
    target_db_player = Player.find_by_discord_id(mentioned_member.id)
    reason = @options[:reason] || "Banned by #{@event.message.author.name} (#{@event.message.author.id})"

    ActiveRecord::Base.transaction do
      BannedUser.create(
        discord_id: mentioned_member.id,
        ban_type: ban_type,
        osu_player: target_db_player,
        created_by: @invoker[:db_player],
        reason: reason
      )

      if ban_type == BannedUser.ban_types[:soft] && @server[:db_server].verified_role_id && mentioned_member.role?(server.verified_role_id)
        mentioned_member.remove_role(@server[:db_server].verified_role_id)
      elsif ban_type == BannedUser.ban_types[:hard]
        @server[:discordrb_server].ban(mentioned_member, 0, reason)
      end
    end
  end
end
