module PlayerStatistics
  class TotalMissesStatistic < PlayerStatistic
    def compute
      q = MatchScore.joins(:match).where(player: @player)

      apply_filter(q).sum(:count_miss)
    end

    protected

    ##
    # Invoked with a query containing all the scores of the current player joined on their matches.
    def apply_filter(query)
      query
    end
  end
end
