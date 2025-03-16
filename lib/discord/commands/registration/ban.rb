require "discordrb"

require_relative "../command_base"

class Ban < CommandBase
  protected

  def required_options
    [["-t TEXT", "--type", "Ban type. One of [soft, hard]. Default is hard ban."], ["-r TEXT", "--reason", "Reason for ban."]]
  end

  def requires_admin?
    true
  end

  def make_response
    mentioned_member = @server[:discordrb_server].member(@event.message.mentions.first&.id)

    return @event.respond("Unable to find user #{mentioned_member.name} in the server") if mentioned_member.nil?

    target_db_player = Player.find_by_discord_id(mentioned_member.id)

    return @event.respond("#{mentioned_member.name} is not registered") if target_db_player.nil? || !target_db_player.osu_verified
    unless target_db_player.ban_status_no_ban?
      return @event.respond("#{mentioned_member.name} is already banned")
    end

    ban_type = Player.ban_status.fetch(@options[:type].to_s, :hard)
    reason = @options[:reason] || "Banned by #{@event.message.author.name} (#{@event.message.author.id})"

    ActiveRecord::Base.transaction do
      BanHistory.create(player: target_db_player, banned_by: @invoker[:db_player], reason: reason, ban_type: ban_type)

      target_db_player.ban_status = ban_type
      target_db_player.save!

      execute_discord_action(mentioned_member, ban_type, reason)
    end
  end

  private

  def execute_discord_action(member, ban_type, reason)
    verified_role_id = @server[:db_server].verified_role_id

    if ban_type == Player.ban_status_soft? && verified_role_id && member.role?(verified_role_id)
      member.remove_role(verified_role_id)
    elsif ban_type == Player.ban_statuses_hard?
      @server[:discordrb_server].ban(member, 0, reason: reason)
    end
  end
end
