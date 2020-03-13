module PlayerStatistics
  class FullCombosStatistic < PlayerStatistic
    def compute
      MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .joins('LEFT JOIN beatmaps ON match_scores.beatmap_id = beatmaps.online_id')
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .select('match_scores.*, matches.*')
        .where(player: @player)
        .where('count_miss = 0 and (beatmaps.max_combo - match_scores.max_combo) <= (0.01 * beatmaps.max_combo)')
        .count(:all)
    end
  end
end
