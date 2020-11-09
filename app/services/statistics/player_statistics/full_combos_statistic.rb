module PlayerStatistics
  class FullCombosStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .joins('LEFT JOIN matches ON match_scores.match_id = matches.id')
        .joins('LEFT JOIN beatmaps ON match_scores.beatmap_id = beatmaps.online_id')
        .select('match_scores.*, matches.*')
        .where(player: @player, is_full_combo: true)

      apply_filters(q).count(:all)
    end

    protected

    ##
    # Invoked with a join query of match scores with matches and beatmap for the given player where the scores meet the
    # criteria for qualifying as a full combo.
    def apply_filters(query)
      query
    end
  end
end
