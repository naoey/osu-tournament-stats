module StatCalculationHelper
  include SemanticLogger::Loggable

  def self.calculate_accuracy(score)
    # https://osu.ppy.sh/help/wiki/Accuracy
    d = 300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)

    if d.zero?
      logger.warn("Denominator for accuracy calculation of score score is zero, using zero acc instead.", score: score)
      return 0
    end

    n = ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300))

    n / d.to_f
  end

  def self.fc?(score, beatmap)
    score["count_miss"].to_i.zero? && (beatmap.max_combo - score["max_combo"].to_i) <= 0.01 * beatmap.max_combo
  end
end
