module PlayerStatistics
  class BestAccuracyStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .joins(:match)
        .where(player: @player)

      acc = apply_filter(q)
        .all
        .map { |s| StatCalculationHelper.calculate_accuracy(s) }
        .max
        &.round(4)

      acc || 0
    end
  end
end

