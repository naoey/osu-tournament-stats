require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'MapsFailedStatisticTest' do
  it 'counts maps failed correctly' do
    player = create(:player)
    create_list(:match_score, 5, pass: false, player: player)

    expect(PlayerStatistics::MapsFailedStatistic.new(player).compute).to equal(5)
  end
end
