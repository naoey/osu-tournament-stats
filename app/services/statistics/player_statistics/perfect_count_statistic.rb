module PlayerStatistics
  class PerfectCountStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .joins(:match)
        .where(player: @player, perfect: true)

      apply_filter(q).count(:all)
    end

    protected

    ##
    # Invoked with a query containing a join of player's scores with matches.
    def apply_filter(query)
      query
    end
  end
end

