module PlayerStatistics
  class MapsPlayedStatistic < PlayerStatistic
    def compute
      q = MatchScore
        .joins(:match)
        .where(player: @player)

      apply_filter(q).count(:all)
    end
  end
end
