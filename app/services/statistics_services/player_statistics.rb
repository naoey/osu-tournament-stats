module StatisticsServices
  ##
  # Service that provides functionality for various player statistics related operations.
  class PlayerStatistics
    def get_all_player_stats_for_tournament(tournament_id, round_name_search = '')
      @data = []

      raise GenericExceptions::NotFoundError 'Tournament not found' if Tournament.find(tournament_id).nil?

      Player.all.each do |player|
        player_scores = MatchScore
          .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
          .joins('LEFT JOIN tournaments ON matches.tournament_id = tournaments.id')
          .select('match_scores.*, matches.round_name')
          .where('tournaments.id = ?', tournament_id)
          .where(player: player)
          .where('matches.round_name like ?', "%#{round_name_search}%")

        next if player_scores.count(:all).zero?

        @data.push(create_player_tournament_statistic(player, player_scores, round_name_search, tournament_id))
      end

      @data
    end

    def get_all_player_stats_for_match(match_id, round_name_search = '')
      @data = []

      match = Match.find(match_id)

      raise GenericExceptions::NotFoundError 'Match not found' if match.nil?

      match.players.each do |player|
        player_scores = MatchScore
          .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
          .joins('LEFT JOIN tournaments ON matches.tournament_id = tournaments.id')
          .select('match_scores.*, matches.round_name')
          .where('match_scores.match_id = ?', match_id)
          .where(player: player)
          .where('matches.round_name like ?', "%#{round_name_search}%")

        next if player_scores.count(:all).zero?

        @data.push(create_player_match_statistic(player, player_scores, round_name_search, match_id))
      end

      @data
    end

    def get_player_stats(player)
      player_scores = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*')
        .where(player: player)

      return {} if player_scores.count(:all).zero?

      create_player_match_statistic(player, player_scores, '', nil)
    end

    def get_player_leaderboard(*player_ids)
      player_scores = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*, matches.*')
        .where(player: player_ids)

      return [] if player_scores.count(:all).zero?
    end

    def calculate_score_accuracy(score)
      # https://osu.ppy.sh/help/wiki/Accuracy
      d = 300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)

      if d.zero?
        Rails.logger.tagged(self.class.name) { Rails.logger.debug "Denominator for accuracy calculation of score #{score.as_json} is zero, using zero acc instead." }
        return 0
      end

      n = ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300))

      n / d.to_f
    end

    private

    # TODO: all these x? methods should take a queryable and get the result
    def matches_played?(player, tournament_id: nil, round_name: nil)
      q = Match
        .joins('JOIN match_teams_players ON match_teams_players.match_team_id IN (matches.red_team_id, matches.blue_team_id)')
        .where('match_teams_players.player_id = ?', player.id)

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.round_name LIKE ?', "%#{round_name}%") unless round_name.nil? || round_name.empty?

      q.count(:all)
    end

    def matches_won?(player, tournament_id: nil, round_name: nil)
      q = Match
        .joins('JOIN match_teams_players ON match_teams_players.match_team_id = matches.winner_id')
        .where('match_teams_players.player_id = ?', player.id)

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.round_name like ?', "%#{round_name}%") unless round_name.nil? || round_name.empty?

      q.count
    end

    def full_combos?(player, tournament_id: nil, match_id: nil, round_name: nil)
      # this is following Potla's formula for approximated FCs since we we can't differentiate sliderbreaks
      # from slider end misses from the scores alone
      q = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .joins('LEFT JOIN beatmaps ON match_scores.beatmap_id = beatmaps.online_id')
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*, matches.*')
        .where(player: player)
        .where('count_miss = 0 and (beatmaps.max_combo - match_scores.max_combo) <= (0.01 * beatmaps.max_combo)')

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.id = ?', match_id) unless match_id.nil?
      q = q.where('matches.round_name like ?', "%#{round_name}%") unless round_name.nil?

      q.count(:all)
    end

    def maps_won?(player, tournament_id: nil, match_id: nil, round_name: nil)
      # FIXME: this monstrosity has to go away aaaaaaa

      player_tournament_fragment = Match.sanitize_sql_for_conditions([
        "match_teams_players.player_id = ? #{!tournament_id.nil? ? "AND matches.tournament_id = ?" : ''}",
        player.id,
        *(tournament_id unless tournament_id.nil?),
      ])

      player_team_fragment = Match.sanitize_sql_for_conditions([
        "player_id = ?",
        player.id,
      ])

      player_match_fragment = Match.sanitize_sql_for_conditions([
        "match_scores.match_id = ?",
        match_id
      ])

      sql = "SELECT COUNT(*) as maps_won FROM (
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
                    WHERE #{player_tournament_fragment}
                  )
                ) AS team_players ON team_players.team_id = match_teams_players.match_team_id
                -- Get scores for these players
                JOIN match_scores ON match_scores.player_id = match_teams_players.player_id AND match_scores.match_id = team_players.match_id
                WHERE #{match_id.nil? ? '' : player_match_fragment}
                GROUP BY team_players.team_id, match_scores.beatmap_id
              )
              GROUP BY beatmap_id
            )
            WHERE team_id IN (SELECT match_team_id FROM match_teams_players WHERE #{player_team_fragment})"

      ActiveRecord::Base.connection.execute(sql)[0]['maps_won']
    end

    # TODO: dedupe all this crap
    def create_player_match_statistic(player, player_scores, round_name_search, match_id)
      player_accuracies = player_scores.map(&method(:calculate_score_accuracy))

      {
        player: player,
        maps_played: player_scores.count(:all),
        maps_won: maps_won?(player, match_id: match_id),
        best_accuracy: (player_accuracies.max * 100.0).round(2),
        average_accuracy: (player_accuracies.reduce(0, :+) / player_accuracies.count.to_f * 100.0).round(2),
        perfect_count: player_scores.where(perfect: true).count(:all),
        average_misses: player_scores.average(:count_miss).round(2),
        total_misses: player_scores.sum(:count_miss),
        average_score: player_scores.average(:score).round(2),
        total_score: player_scores.sum(:score),
        maps_failed: player_scores.where(player_id: player.id, pass: false).count(:all),
        full_combos: full_combos?(player),
      }
    end

    def create_player_tournament_statistic(player, player_scores, round_name_search, tournament_id)
      player_accuracies = player_scores.map(&method(:calculate_score_accuracy))

      {
        player: player,
        matches_played: matches_played?(player, tournament_id: tournament_id, round_name: round_name_search),
        matches_won: matches_won?(player, tournament_id: tournament_id, round_name: round_name_search),
        maps_played: player_scores.count(:all),
        maps_won: maps_won?(player, tournament_id: tournament_id, round_name: round_name_search),
        best_accuracy: (player_accuracies.max * 100.0).round(2),
        average_accuracy: (player_accuracies.reduce(0, :+) / player_accuracies.count.to_f * 100.0).round(2),
        perfect_count: player_scores.where(perfect: true).count(:all),
        average_misses: player_scores.average(:count_miss).round(2),
        total_misses: player_scores.sum(:count_miss),
        average_score: player_scores.average(:score).round(2),
        total_score: player_scores.sum(:score),
        maps_failed: player_scores.where(player_id: player.id, pass: false).count(:all),
        full_combos: full_combos?(player, tournament_id: tournament_id, round_name: round_name_search),
      }
    end
  end
end
