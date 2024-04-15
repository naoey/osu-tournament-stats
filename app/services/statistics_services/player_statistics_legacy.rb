module StatisticsServices
  ##
  # Service that provides functionality for various player statistics related operations.
  class PlayerStatistics_Legacy
    def get_all_player_stats_for_tournament(tournament_id, round_name_search = "")
      @data = []

      raise GenericExceptions.NotFoundError "Tournament not found" if Tournament.find(tournament_id).nil?

      Player.all.each do |player|
        player_scores =
          MatchScore
            .joins("LEFT JOIN matches ON match_scores.match_id = matches.id")
            .joins("LEFT JOIN tournaments ON matches.tournament_id = tournaments.id")
            .select("match_scores.*, matches.round_name")
            .where("tournaments.id = ?", tournament_id)
            .where(player: player)
            .where("matches.round_name like ?", "%#{round_name_search}%")

        next if player_scores.count(:all).zero?

        @data.push(create_player_tournament_statistic(player, player_scores, round_name_search, tournament_id))
      end

      @data
    end

    def get_all_player_stats_for_match(match_id, round_name_search = "")
      @data = []

      match = Match.find(match_id)

      raise GenericExceptions.NotFoundError "Match not found" if match.nil?

      match.players.each do |player|
        player_scores =
          MatchScore
            .joins("LEFT JOIN matches ON match_scores.match_id = matches.id")
            .joins("LEFT JOIN tournaments ON matches.tournament_id = tournaments.id")
            .select("match_scores.*, matches.round_name")
            .where("match_scores.match_id = ?", match_id)
            .where(player: player)
            .where("matches.round_name like ?", "%#{round_name_search}%")

        next if player_scores.count(:all).zero?

        @data.push(create_player_match_statistic(player, player_scores, round_name_search, match_id))
      end

      @data
    end

    def get_player_stats(player)
      player_scores =
        MatchScore.joins("LEFT JOIN matches ON match_scores.match_id = matches.id").select("match_scores.*").where(player: player)

      return {} if player_scores.count(:all).zero?

      create_player_match_statistic(player, player_scores, "", nil)
    end

    def get_player_leaderboard(*player_ids)
      player_scores =
        MatchScore
          .joins("LEFT JOIN matches ON match_scores.match_id = matches.id")
          .select("match_scores.*, matches.*")
          .where(player: player_ids)

      return [] if player_scores.count(:all).zero?
    end

    def calculate_score_accuracy(score)
      # https://osu.ppy.sh/help/wiki/Accuracy
      d = 300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)

      if d.zero?
        Rails
          .logger
          .tagged(self.class.name) do
            Rails.logger.debug "Denominator for accuracy calculation of score #{score.as_json} is zero, using zero acc instead."
          end
        return 0
      end

      n = ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300))

      n / d.to_f
    end

    private

    # TODO: all these x? methods should take a queryable and get the result
    def matches_played?(player, tournament_id: nil, round_name: nil)
      q =
        Match.joins(
          "JOIN match_teams_players ON match_teams_players.match_team_id IN (matches.red_team_id, matches.blue_team_id)"
        ).where("match_teams_players.player_id = ?", player.id)

      q = q.where("matches.tournament_id = ?", tournament_id) unless tournament_id.nil?
      q = q.where("matches.round_name LIKE ?", "%#{round_name}%") unless round_name.nil? || round_name.empty?

      q.count(:all)
    end

    def matches_won?(player, tournament_id: nil, round_name: nil)
      q =
        Match.joins("JOIN match_teams_players ON match_teams_players.match_team_id = matches.winner_id").where(
          "match_teams_players.player_id = ?",
          player.id
        )

      q = q.where("matches.tournament_id = ?", tournament_id) unless tournament_id.nil?
      q = q.where("matches.round_name like ?", "%#{round_name}%") unless round_name.nil? || round_name.empty?

      q.count
    end

    def full_combos?(player, tournament_id: nil, match_id: nil, round_name: nil)
      # this is following Potla's formula for approximated FCs since we we can't differentiate sliderbreaks
      # from slider end misses from the scores alone
      q =
        MatchScore
          .joins("LEFT JOIN matches ON match_scores.match_id = matches.id")
          .select("match_scores.*, matches.*")
          .where("player_id = #{player.id} AND is_full_combo = 1")

      q = q.where("matches.tournament_id = ?", tournament_id) unless tournament_id.nil?
      q = q.where("matches.id = ?", match_id) unless match_id.nil?
      q = q.where("matches.round_name like ?", "%#{round_name}%") unless round_name.nil?

      q.all.map(&:beatmap_id)
    end

    def maps_won?(player, tournament_id: nil, match_id: nil, round_name: nil)
      q =
        MatchScore
          .joins("LEFT JOIN matches ON match_scores.match_id = matches.id")
          .joins("LEFT JOIN beatmaps ON match_scores.beatmap_id = beatmaps.id")
          .select("match_scores.*, matches.*")
          .where("player_id = #{player.id} AND is_win = 1")

      q = q.where("matches.tournament_id = ?", tournament_id) unless tournament_id.nil?
      q = q.where("matches.id = ?", match_id) unless match_id.nil?
      q = q.where("matches.round_name like ?", "%#{round_name}%") unless round_name.nil?

      q.all.map(&:beatmap_id)
    end

    def best_accuracy?(scores)
      best = scores.max_by(&:accuracy)

      { accuracy: (best.accuracy * 100).round(2), beatmap_id: best.beatmap.id }
    end

    # TODO: dedupe all this crap
    def create_player_match_statistic(player, player_scores, _round_name_search, match_id)
      {
        player: player,
        maps_played: player_scores.all.map(&:beatmap_id).uniq,
        maps_won: maps_won?(player, match_id: match_id),
        best_accuracy: best_accuracy?(player_scores),
        average_accuracy: (player_scores.sum(:accuracy) / player_scores.count(:accuracy).to_f * 100.0).round(2),
        perfect_maps: player_scores.where(perfect: true).all.map(&:beatmap_id).uniq,
        average_misses: player_scores.average(:count_miss).round(2),
        total_misses: player_scores.sum(:count_miss),
        average_score: player_scores.average(:score).round(2),
        total_score: player_scores.sum(:score),
        maps_failed: player_scores.where(player_id: player.id, pass: false).all.map(&:beatmap_id).uniq,
        full_combos: full_combos?(player, match_id: match_id)
      }
    end

    def create_player_tournament_statistic(player, player_scores, round_name_search, tournament_id)
      {
        player: player,
        matches_played: matches_played?(player, tournament_id: tournament_id, round_name: round_name_search),
        matches_won: matches_won?(player, tournament_id: tournament_id, round_name: round_name_search),
        maps_played: player_scores.all.map(&:beatmap_id).uniq,
        maps_won: maps_won?(player, tournament_id: tournament_id, round_name: round_name_search),
        best_accuracy: best_accuracy?(player_scores),
        average_accuracy: (player_scores.sum(:accuracy) / player_scores.count(:accuracy).to_f * 100.0).round(2),
        perfect_maps: player_scores.where(perfect: true).all.map(&:beatmap_id).uniq,
        average_misses: player_scores.average(:count_miss).round(2),
        total_misses: player_scores.sum(:count_miss),
        average_score: player_scores.average(:score).round(2),
        total_score: player_scores.sum(:score),
        maps_failed: player_scores.where(player_id: player.id, pass: false).all.map(&:beatmap_id).uniq,
        full_combos: full_combos?(player, tournament_id: tournament_id, round_name: round_name_search)
      }
    end
  end
end
