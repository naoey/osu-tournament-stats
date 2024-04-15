require_relative "./command_base"

class MatchStats < CommandBase
  protected

  def required_options
    [["-i ID", "--id", 'Match ID to show stats for. Use \'last\' to get latest match stats']]
  end

  def make_response
    if @options[:id].nil? || @options[:id] == "last"
      return @event.respond("No matches found!") if Match.last.nil?

      id = Match.last.id
    elsif @options[:id].to_i <= 0
      # apparently in ruby converting NaN string to number also yields zero so this should handle that case
      # 'test'.to_i => 0
      return @event.respond("Match ID must be an integer greater than 0!")
    else
      id = @options[:id]
    end

    begin
      match = Match.find(id)
    rescue ActiveRecord::RecordNotFound
      return @event.respond("Match does not exist")
    end

    stats =
      StatisticsServices::PlayerStatistics_Legacy
        .new
        .get_all_player_stats_for_match(id)
        .sort_by { |s| s[:average_score] }
        .reverse
        .map { |stat| [stat[:player].name, stat[:total_score], stat[:average_score], stat[:average_accuracy].round(2)] }

    headers = ["Name", "Total score", "Average score", "Average acc"]

    web_url = "https://osu.naoey.pw/matches/#{id}"

    text =
      "Stats for **#{match.round_name}**" \
        "#{match.tournament.nil? ? "" : " (#{match.tournament.name})"}" \
        "\n```" \
        "#{MarkdownTables.plain_text(MarkdownTables.make_table(headers, stats, is_rows: true))}" \
        "```" \
        "\nView full stats at #{web_url}"

    if text.length > 2000
      @event.respond("Stats exceed Discord message length limit, see the full stats at #{web_url}")
    else
      @event.respond(text)
    end
  end
end
