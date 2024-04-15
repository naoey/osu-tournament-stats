module PlayerStatistics
  class TotalScoreStatistic < PlayerStatistic
    def compute
      q = MatchScore.where(player: @player)

      apply_filter(q).sum(:score)
    end

    protected

    ##
    # Invoked with a query containing all [MatchScore](#MatchScore)s for the current player.
    def apply_filter(query)
      query
    end
  end
end
