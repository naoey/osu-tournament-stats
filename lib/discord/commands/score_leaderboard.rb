require 'discordrb';

require_relative './command_base'
require_relative '../../../app/services/leaderboards/player_leaderboard'

class ScoreLeaderboard < CommandBase
  def initialize(*args)
    @current_page = 0
    @total_pages = (PlayerLeaderboard.get_leaderboard.length / 10).ceil

    super
  end

  protected

  def required_options
    [
      ['-s TEXT', '--sort TEXT', 'Sort by one of (name, score, play_count, accuracy)'],
      ['-d', '--descending', 'Sort in descending order; sorts ascending if omitted'],
    ]
  end

  def make_response
    begin
      scores = get_leaderboard(10, 0, order: @options[:sort], descending: @options[:descending]).map(&:values)

      message = event.respond(make_text(scores))

      left_emoji = "\u2B05"
      right_emoji = "\u27A1"

      if @total_pages > 1
        message.create_reaction(left_emoji)
        message.create_reaction(right_emoji)
      end

      @client.add_await(:"next_page_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: right_emoji) do |reaction_event|
        next true unless reaction_event.message.id == message.id

        if @current_page == @total_pages - 1
          message.delete_reaction(reaction_event.user, right_emoji)
          next
        end

        @current_page += 1

        message.delete_reaction(reaction_event.user, right_emoji)
        message.edit(make_text(get_leaderboard(10, @current_page * 10, true).map(&:values)))
      end

      @client.add_await(:"previous_page_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: left_emoji) do |reaction_event|
        next true unless reaction_event.message.id == message.id

        if @current_page.zero?
          message.delete_reaction(reaction_event.user, left_emoji)
          next
        end

        @current_page -= 1

        message.delete_reaction(reaction_event.user, left_emoji)
        message.edit(make_text(get_leaderboard(10, @current_page * 10, true).map(&:values)))
      end
    rescue StandardError => e
      Rails.logger.tagged(self.class.name) { Rails.logger.error e }
      'Error retrieving stats'
    end
  end

  private

  def make_text(data)
    sort_indicator = @options[:descending] ? ' ▼' : ' ▲'
    sort_criteria_idx = PlayerLeaderboard::ORDERING.keys.find_index(@options[:sort])

    labels = ['Player', 'Average score', 'Average accuracy', 'Maps played']

    labels[sort_criteria_idx].concat(sort_indicator)

    "```#{MarkdownTables.plain_text(MarkdownTables.make_table(labels, data, is_rows: true))}\n\nPage #{@current_page + 1} of #{@total_pages}```"
  end
end
