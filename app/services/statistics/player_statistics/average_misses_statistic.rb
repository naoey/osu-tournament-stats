module PlayerStatistics
  class AverageMissesStatistic < PlayerStatistic
    def compute
      q = MatchScore.joins(:match).where(player: @player)

      apply_filter(q).average(:count_miss).to_f
    end

    protected

    ##
    # Invoked with a query containing a list of the current player's scores joined on their respective matches.
    def apply_filter(query)
      query
    end
  end
end
