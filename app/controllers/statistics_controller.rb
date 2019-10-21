class StatisticsController < ApplicationController
  def show_all_players
    @data = []

    Player.all.each do |player|
      player_scores = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .joins('LEFT JOIN tournaments ON matches.tournament_id = tournaments.id')
        .select('match_scores.*, matches.round_name')
        .where(player: player)

      player_scores = player_scores.where('matches.round_name like ?', "%#{params[:match_name]}%") if params[:match_name]

      if params[:tournament_name]
        player_scores = player_scores.where('tournaments.name like ?', "%#{params[:tournament_name]}%")
      end

      next if player_scores.count(:all) == 0

      player_accuracies = player_scores.map(&method(:score_accuracy))

      matches_won_query = matches_won_query
        .joins('LEFT JOIN match_teams ON matches.winner_id = match_teams.id')
        .joins('LEFT JOIN match_teams_players ON match_teams.id = match_teams_players.match_team_id')
        .joins('LEFT JOIN players ON match_teams_players.id = players.id')
        .where('players.id = ?', player.id)

      @data.push(
        player: player,
        matches_played: player_scores.distinct.count(:match_id),
        matches_won: matches_won_query.count(:id),
        maps_played: player_scores.count(:all),
        # TODO: figure out how to do a count where for maps won in the DB itself o.o
        maps_won: player_scores
          .select('match_scores.beatmap_id, MAX(match_scores.score), match_scores.player_id, matches.round_name')
          .group(:beatmap_id, :match_id)
          .where(pass: true)
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
          .select('match_scores.beatmap_id, match_scores.player_id, match_scores.count_miss, match_scores.max_combo, beatmaps.max_combo')
          .where('count_miss = 0 and (beatmaps.max_combo - match_scores.max_combo) <= (0.01 * beatmaps.max_combo)')
          .count(:all)
      )
    end

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  private

  def score_accuracy(score)
    # https://osu.ppy.sh/help/wiki/Accuracy
    ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300)) / (300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300))
      .to_f
  end
end
