module PlayerStatistics
  class AverageScoreStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .where(player: @player)

      # TODO: check why this is returning BigDecimal, this cast to float should be unnecessary
      apply_filter(q).average(:score)&.round(2).to_f || 0
    end

    protected

    ##
    # Invoked with a query containing all the [MatchScore](#MatchScore)s of this player.
    def apply_filter(query)
      query
    end
  end
end
