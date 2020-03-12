module PlayerStatistics
  ##
  # Statistic that computes how many matches a given [Player](#Player) has participated in.
  class MatchesPlayedStatistic < PlayerStatistics::PlayerStatistic
    def compute
      query = Match
        .joins('JOIN match_teams_players ON match_teams_players.match_team_id IN (matches.red_team_id, matches.blue_team_id)')
        .where('match_teams_players.player_id = ?', player.id)

      query = apply_filter(query)

      query.count(:all)
    end

    protected

    ##
    # Applies a filter to the Match query and returns the query. Is called with a query consisting of a join on matches
    # and match teams that contains a result of all matches and teams the current player has participated in.
    def apply_filter(match_query)
      match_query
    end
  end
end
