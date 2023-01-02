require 'discordrb'

require_relative './command_base'
require_relative '../../../app/services/leaderboards/player_leaderboard'

class ExpLeaderboard < CommandBase
  def initialize(*args)
    super

    @current_page = 1
    @total_pages = get_leaderboard.total_pages
  end

  protected

  def make_response
    begin
      @message = @event.respond(make_text)

      if @total_pages > 1
        @message.create_reaction(LEFT_EMOJI)
        @message.create_reaction(RIGHT_EMOJI)
      end

      add_next_hook
      add_previous_hook
      add_cleanup

      nil
    rescue StandardError => e
      Rails.logger.tagged(self.class.name) { Rails.logger.error e }
      'Error retrieving stats'
    end
  end

  private

  def add_next_hook
    Discord::OsuDiscordBot.instance.client.add_await(
      :"next_page_#{@message.id}",
      Discordrb::Events::ReactionAddEvent,
      emoji: RIGHT_EMOJI
    ) do |reaction_event|
      next true unless reaction_event.message.id == @message.id

      return true if @explode

      if @current_page == @total_pages
        @message.delete_reaction(reaction_event.user, RIGHT_EMOJI)
        next
      end

      @current_page += 1

      @message.delete_reaction(reaction_event.user, RIGHT_EMOJI)
      @message.edit(make_text)

      false
    end
  end

  def add_previous_hook
    Discord::OsuDiscordBot.instance.client.add_await(
      :"previous_page_#{@message.id}",
      Discordrb::Events::ReactionAddEvent,
      emoji: LEFT_EMOJI
    ) do |reaction_event|
      next true unless reaction_event.message.id == @message.id

      return true if @explode

      if @current_page == 1
        @message.delete_reaction(reaction_event.user, LEFT_EMOJI)
        next
      end

      @current_page -= 1

      @message.delete_reaction(reaction_event.user, LEFT_EMOJI)
      @message.edit(make_text)

      false
    end
  end

  def add_cleanup
    Thread.new do
      sleep 60
      @message.delete_own_reaction(LEFT_EMOJI)
      @message.delete_own_reaction(RIGHT_EMOJI)
      @explode = true
    end
  end

  def make_text
    data = get_leaderboard.each_with_index.map { |d, i|
      [i + 1 + @current_page * 10, d.player.name, d.level, d.exp, d.message_count]
    }

    sort_indicator = @options[:ascending] ? ' ▲' : ' ▼'
    # sort_criteria_idx = ORDERING.keys.find_index(@options[:sort].to_sym) if @options[:sort]
    sort_criteria_idx ||= 2

    labels = ['Rank', 'User', 'Level', 'Exp', 'Messages']

    labels[sort_criteria_idx].concat(sort_indicator)

    "```#{MarkdownTables.plain_text(MarkdownTables.make_table(labels, data, is_rows: true))}\n\nPage #{@current_page + 1} of #{@total_pages}```\nView in browser: https://osu.naoey.pw/discord/servers/1/exp"
  end

  def get_leaderboard()
    DiscordExp
      .where(discord_server_id: @server[:db_server])
      .order(exp: :desc, player_id: :asc)
      .includes(%i[player])
      .page(@current_page)
      .per(10)
  end
end
