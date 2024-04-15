module PlayerStatistics
  class MapsWonStatistic < PlayerStatistic
    def compute
      player_team_fragment = Match.sanitize_sql_for_conditions(["player_id = ?", @player.id])

      # TODO: there HAS to be a better way to compute this
      sql =
        "SELECT COUNT(*) as maps_won FROM (
              SELECT MAX(team_total_score), team_id FROM (
                -- Get all players in a given set of teams
                SELECT SUM(match_scores.score) as team_total_score, match_scores.beatmap_id, team_players.match_id, match_teams_players.player_id, team_players.team_id FROM match_teams_players
                JOIN (
                  -- Get all teams in given set of matches
                  SELECT * FROM (
                    SELECT id as match_id, red_team_id AS team_id FROM matches
                    UNION ALL
                    SELECT id, blue_team_id AS team_id FROM matches
                  ) AS teams_in_matches
                  WHERE teams_in_matches.match_id IN (
                    -- Get all matches that a player participated in
                    SELECT matches.id FROM matches
                    JOIN match_teams_players ON match_team_id IN (matches.red_team_id, matches.blue_team_id)
                  )
                ) AS team_players ON team_players.team_id = match_teams_players.match_team_id
                -- Get scores for these players
                JOIN match_scores ON match_scores.player_id = match_teams_players.player_id AND match_scores.match_id = team_players.match_id
                GROUP BY team_players.team_id, match_scores.beatmap_id
              ) AS total_scores
              GROUP BY beatmap_id
            ) AS total_team_scores
            WHERE team_id IN (SELECT match_team_id FROM match_teams_players WHERE #{player_team_fragment})"

      ActiveRecord::Base.connection.execute(sql)[0]["maps_won"]
    end

    protected

    ##
    # Not allowed on this stat because the SQL is weird and handwritten
    def apply_filters
      raise NotImplementedError,
            "#{self.class.name} does not allow queryable filtering, use apply_tournament_filter, apply_match_filter instead"
    end
  end
end
