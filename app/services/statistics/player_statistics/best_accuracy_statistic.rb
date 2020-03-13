module PlayerStatistics
  class BestAccuracyStatistic < PlayerStatistic
    include AccuracyHelper

    def compute
      q = MatchScore
        .joins(:match)
        .where(player: @player)

      acc = apply_filter(q)
        .all
        .map(&:calculate_accuracy)
        .max
        &.round(4)

      acc || 0
    end
  end
end

