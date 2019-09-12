module StatisticsServices
  ##
  # Service that provides functionality for various player statistics related operations.
  class PlayerStatisticsService
    def get_player_stats_for_tournament(tournament_id, round_name_search = '')
      @data = []

      Player.all.each { |player|
        player_scores = MatchScore
          .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
          .joins('LEFT JOIN tournaments ON matches.tournament_id = tournaments.id')
          .select('match_scores.*, matches.round_name')
          .where('tournaments.id = ?', tournament_id)
          .where(player: player)
          .where('matches.round_name like ?', "%#{round_name_search}%")

        next if player_scores.count(:all).zero?

        @data.push(create_player_statistic(player, player_scores, round_name_search, tournament_id))
      }

      @data
    end

    private

    def score_accuracy(score)
      # https://osu.ppy.sh/help/wiki/Accuracy
      d = 300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)

      if d.zero?
        Rails.logger.warn "Denominator for accuracy calculation of score #{score.as_json} is zero, using zero acc instead."
        return 0
      end

      n = ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300))

      n / d.to_f
    end

    def create_player_statistic(player, player_scores, round_name_search, tournament_id)
      # FIXME: check why there is a random nil for some scores here
      player_accuracies = player_scores.map(&method(:score_accuracy))

      {
        player: player.as_json.slice("id", "name"),
        matches_played: Match
          .joins('JOIN matches AS player_matches ON matches.id = player_matches.id')
          .where('matches.tournament_id = ?', tournament_id)
          .where('matches.round_name like ?', "%#{round_name_search}%")
          .where('player_matches.player_red_id = ? OR player_matches.player_blue_id = ?', player.id, player.id)
          .count,
        matches_won: Match
          .where('tournament_id = ?', tournament_id)
          .where('round_name like ?', "%#{round_name_search}%")
          .where(winner: player.id).count,
        maps_played: player_scores.count(:all),
        # TODO: figure out how to do a count where for maps won in the DB itself o.o
        maps_won: MatchScore
          .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
          .select('match_scores.beatmap_id, MAX(match_scores.score), match_scores.player_id, matches.round_name, matches.tournament_id')
          .group(:beatmap_id, :match_id)
          .where('matches.tournament_id = ?', tournament_id)
          .where(pass: true)
          .where('matches.round_name like ?', "%#{round_name_search}%")
          .all
          .to_a
          .select { |s| s.player_id == player.id }
          .length,
        best_accuracy: (player_accuracies.max * 100.0).round(2),
        average_accuracy: (player_accuracies.reduce(0, :+) / player_accuracies.count.to_f * 100.0).round(2),
        perfect_count: player_scores.where(perfect: true).count(:all),
        average_misses: player_scores.average(:count_miss).round(2),
        total_misses: player_scores.sum(:count_miss),
        average_score: player_scores.average(:score).round(2),
        total_score: player_scores.sum(:score),
        maps_failed: player_scores.where(player_id: player.id, pass: false).count(:all),
        full_combos: player_scores
          .joins('LEFT JOIN beatmaps ON match_scores.beatmap_id = beatmaps.online_id')
          .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
          .select('match_scores.beatmap_id, match_scores.player_id, match_scores.count_miss, match_scores.max_combo, beatmaps.max_combo')
          .where('matches.tournament_id = ?', tournament_id)
          .where('count_miss = 0 and (beatmaps.max_combo - match_scores.max_combo) <= (0.01 * beatmaps.max_combo)')
          .count(:all),
      }
    end
  end
end
