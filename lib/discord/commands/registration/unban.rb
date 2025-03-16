require "discordrb"

require_relative "../command_base"

class Unban < CommandBase
  protected

  def required_options
    [["-d INTEGER", "--discord-id", "Discord ID linked to the user"], ["-o INTEGER", "--osu-id", "osu! ID to unban"]]
  end

  def requires_admin?
    true
  end

  def make_response
    return @event.respond("No user specified to unregister") if @event.message.mentions.length.zero?

    return @event.respond("Mention a single user to unregister") if @event.message.mentions.length > 1

    mentioned_member = @event.message.server.member(@event.message.mentions.first.id)

    player = nil

    if mentioned_member
      player = Player.find_by(discord_id: mentioned_member.id)
    elsif @options[:osu_id]
      player = Player.find_by(osu_id: @options[:osu_id])
    elsif @options[:discord_id]
      player = Player.find_by(discord_id: @options[:discord_id])
    end

    return @event.respond("User not found") if player.nil?
    return @event.respond("User #{player.name} is not banned") if player.ban_status_no_ban?

    ActiveRecord::Base.transaction do
      BanHistory.create(
        player: player,
        banned_by: @invoker[:db_player],
        reason: "Unbanned by #{@invoker[:discordrb_user].name} (#{@invoker[:discordrb_user].id})",
        ban_type: BanHistory.ban_types[:no_ban]
      )

      player.ban_status_no_ban!
      player.save!

      @event.respond("Unbanned #{mentioned_member.name}")
    end
  end
end
