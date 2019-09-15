module StatisticsServices
  ##
  # Service that provides functionality for various player statistics related operations.
  class PlayerStatistics
    def get_all_player_stats_for_tournament(tournament_id, round_name_search = '')
      @data = []

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

    def get_player_stats(player)
      player_scores = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*')
        .where(player: player)

      return {} if player_scores.count(:all).zero?

      create_player_match_statistic(player, player_scores)
    end

    def get_player_leaderboard(*player_ids)
      player_scores = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*, matches.*')
        .where(player: player_ids)

      return [] if player_scores.count(:all).zero?
    end

    private

    def score_accuracy(score)
      # https://osu.ppy.sh/help/wiki/Accuracy
      d = 300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)

      if d.zero?
        Rails.logger.tagged(self.class.name) { Rails.logger.debug "Denominator for accuracy calculation of score #{score.as_json} is zero, using zero acc instead." }
        return 0
      end

      n = ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300))

      n / d.to_f
    end

    # TODO: all these x? methods should take a queryable and get the result
    def matches_played?(player, tournament_id: nil, round_name: nil)
      q = Match
        .joins('JOIN matches AS player_matches ON matches.id = player_matches.id')
        .where('player_matches.player_red_id = ? OR player_matches.player_blue_id = ?', player.id, player.id)

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.round_name like ?', "%#{round_name}%") unless round_name.nil?

      q.count
    end

    def matches_won?(player, tournament_id: nil, round_name: nil)
      q = Match.where(winner: player.id)

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.round_name like ?', "%#{round_name}%") unless round_name.nil?

      q.count
    end

    def full_combos?(player, tournament_id: nil, round_name: nil)
      q = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .joins('LEFT JOIN beatmaps ON match_scores.beatmap_id = beatmaps.online_id')
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*, matches.*')
        .where(player: player)
        .where('count_miss = 0 and (beatmaps.max_combo - match_scores.max_combo) <= (0.01 * beatmaps.max_combo)')

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.round_name like ?', "%#{round_name}%") unless round_name.nil?

      q.count(:all)
    end

    def maps_won?(player, tournament_id: nil, round_name: nil)
      # TODO: figure out how to do a count where for maps won in the DB itself o.o
      q = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.beatmap_id, MAX(match_scores.score), match_scores.player_id, matches.round_name, matches.tournament_id')
        .group(:beatmap_id, :match_id)
        .where(pass: true)

      q = q.where('matches.tournament_id = ?', tournament_id) unless tournament_id.nil?
      q = q.where('matches.round_name like ?', "%#{round_name}%") unless round_name.nil?

      q
        .all
        .to_a
        .select { |s| s.player_id == player.id }
        .length
    end

    def create_player_match_statistic(player, player_scores)
      player_accuracies = player_scores.map(&method(:score_accuracy))

      {
        player: player.as_json.slice('id', 'name'),
        matches_played: matches_played?(player),
        matches_won: matches_won?(player),
        maps_played: player_scores.count(:all),
        maps_won: maps_won?(player),
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
      player_accuracies = player_scores.map(&method(:score_accuracy))

      {
        player: player.as_json.slice('id', 'name'),
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
