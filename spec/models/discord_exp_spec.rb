require "rails_helper"

RSpec.describe DiscordExp do
  it "should merge exp correctly" do
    exp1 = DiscordExp.create!(
      exp: 3_589_402,
      detailed_exp: [65_047, 81_895, 3_589_402],
      level: 124,
      message_count: 179_496,
    )
    exp2 = DiscordExp.create!(
      exp: 2_351_348,
      detailed_exp: [50_373, 61_580, 2_351_348],
      level: 107,
      message_count: 117_594
    )
    expected = DiscordExp.create!(
      exp: 5_940_750,
      detailed_exp: [5_940_750]
    )
  end
end
