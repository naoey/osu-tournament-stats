require 'discordrb';

require_relative './command_base'
require_relative '../../../app/services/leaderboards/player_leaderboard'

LEFT_EMOJI = "\u2B05".freeze
RIGHT_EMOJI = "\u27A1".freeze
PAGE_SIZE = 10

class ScoreLeaderboard < CommandBase
  include PlayerLeaderboard

  def initialize(*args)
    @current_page = 0
    @total_pages = (get_leaderboard.length / PAGE_SIZE).ceil

    super
  end

  protected

  def required_options
    [
      ['-s TEXT', '--sort TEXT', 'Sort by one of (name, score, play_count, accuracy)'],
      ['-a', '--ascending', 'Sort in ascending order; sorts descending if omitted'],
    ]
  end

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

      if @current_page == @total_pages - 1
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

      if @current_page.zero?
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
    data = get_leaderboard(
      PAGE_SIZE,
      @current_page * PAGE_SIZE,
      order: @options[:sort],
      ascending: @options[:ascending],
    ).map(&:values)

    sort_indicator = @options[:ascending] ? ' ▲' : ' ▼'
    sort_criteria_idx = ORDERING.keys.find_index(@options[:sort].to_sym) if @options[:sort]
    sort_criteria_idx ||= 1

    labels = ['Player', 'Average score', 'Average accuracy', 'Play count']

    labels[sort_criteria_idx].concat(sort_indicator)

    "```#{MarkdownTables.plain_text(MarkdownTables.make_table(labels, data, is_rows: true))}\n\nPage #{@current_page + 1} of #{@total_pages}```"
  end
end
