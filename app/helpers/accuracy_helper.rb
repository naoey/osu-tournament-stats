module AccuracyHelper
  def self.calculate_accuracy(score)
    # https://osu.ppy.sh/help/wiki/Accuracy
    d = 300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)

    if d.zero?
      Rails.logger.tagged(self.class.name) { Rails.logger.debug "Denominator for accuracy calculation of score #{score} is zero, using zero acc instead." }
      return 0
    end

    n = ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300))

    n / d.to_f
  end
end
