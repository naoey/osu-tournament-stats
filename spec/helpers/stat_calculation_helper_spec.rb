require "rails_helper"

require_relative "../../app/helpers/stat_calculation_helper.rb"

describe "AccuracyHelperTest" do
  it "returns zero when hit counts are zero" do
    score = create(:match_score, count_miss: 0, count_300: 0, count_100: 0, count_50: 0, count_katu: 0, count_geki: 0)

    expect(StatCalculationHelper.calculate_accuracy(score)).to equal(0)
  end

  it "returns expected accuracy for a valid scores" do
    score = create(:match_score, count_miss: 0, count_300: 10, count_100: 0, count_50: 0, count_katu: 0, count_geki: 0)

    expect(StatCalculationHelper.calculate_accuracy(score)).to equal(1.0)

    score.count_300 = 7
    score.count_100 = 3
    score.save!

    expect(StatCalculationHelper.calculate_accuracy(score)).to equal(0.8)

    score.count_300 = 4
    score.count_100 = 4
    score.count_50 = 3
    score.save!

    expect(StatCalculationHelper.calculate_accuracy(score)).to be_within(0.01).of(0.5303)
  end
end
