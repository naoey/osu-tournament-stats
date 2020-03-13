module PlayerStatistics
  class MapsFailedStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .where(player: @player)

      apply_filters(q).count(:all)
    end

    protected

    ##
    # Invoked with a query containing all the [MatchScore](#MatchScore)s for this player. Expected
    # to return the same query after any additional where queries.
    def apply_filters(query)
      query
    end
  end
end
