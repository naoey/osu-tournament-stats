require "rails_helper"

RSpec.describe DiscordExp do
  logger = SemanticLogger['DiscordExpSpec']

  test_server = nil

  before do
    test_server = create(:discord_server)
  end

  it "should merge exp correctly when there is no level up" do
    exp1 = DiscordExp.new(
      exp: 16,
      detailed_exp: [16, 100, 16],
      level: 0,
      message_count: 1,
      player: create(:player),
      discord_server: test_server,
    )
    exp2 = DiscordExp.new(
      exp: 60,
      detailed_exp: [60, 100, 60],
      level: 0,
      message_count: 5,
      player: create(:player),
      discord_server: test_server,
    )
    expected = DiscordExp.new(
      exp: 76,
      detailed_exp: [76, 100, 76],
      level: 0,
      message_count: 6,
      player: exp1.player,
      discord_server: test_server,
    )

    result = exp1.merge(exp2)

    expect(result.exp).to equal(76)
    expect(result.detailed_exp).to eq([76, 100, 76])
    expect(result.level).to equal(0)
    expect(result.message_count).to equal(6)
    expect(result.player_id).to equal(exp1.player.id)
  end

  it "should merge exp correctly when there is level up" do
    exp1 = DiscordExp.new(
      exp: 40,
      detailed_exp: [40, 100, 40],
      level: 0,
      message_count: 3,
      player: create(:player),
      discord_server: test_server,
    )
    exp2 = DiscordExp.new(
      exp: 765,
      detailed_exp: [290, 295, 765],
      level: 3,
      message_count: 100,
      player: create(:player),
      discord_server: test_server,
    )

    result = exp1.merge(exp2)

    expect(result.exp).to equal(805)
    expect(result.detailed_exp).to eq([230, 295, 805])
    expect(result.level).to equal(4)
    expect(result.message_count).to equal(103)
    expect(result.player_id).to equal(exp1.player.id)
  end

  it "should delete the other exp after merging" do
    exp1 = DiscordExp.new(
      exp: 40,
      detailed_exp: [40, 100, 40],
      level: 0,
      message_count: 3,
      player: create(:player),
      discord_server: test_server,
    )
    exp2 = DiscordExp.new(
      exp: 765,
      detailed_exp: [290, 295, 765],
      level: 3,
      message_count: 100,
      player: create(:player),
      discord_server: test_server,
    )

    exp1.merge(exp2)

    expect(exp2).to receive(:destroy!)
  end

  xit "should merge exp correctly with random exp case" do
    exp1 = DiscordExp.new(
      exp: 3_589_402,
      detailed_exp: [65_047, 81_895, 3_589_402],
      level: 124,
      message_count: 179_496,
    )
    exp2 = DiscordExp.new(
      exp: 2_351_348,
      detailed_exp: [50_373, 61_580, 2_351_348],
      level: 107,
      message_count: 117_594
    )
    expected = DiscordExp.new(
      exp: 5_940_750,
      detailed_exp: [0, 100, 5_940_750]
    )

    expect(exp1.merge(exp2).attributes).to eq(expected.attributes)
  end
end
