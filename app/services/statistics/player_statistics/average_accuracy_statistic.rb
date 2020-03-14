module PlayerStatistics
  class AverageAccuracyStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .joins(:match)
        .where(player: @player)

      scores = apply_filter(q)
        .all

      return 0 if scores.count(:all).zero?

      acc = scores
        .map { |s| AccuracyHelper.calculate_accuracy(s) }
        &.reduce(:+)

      (acc / scores.count(:all).to_f).round(4)
    end
  end
end
