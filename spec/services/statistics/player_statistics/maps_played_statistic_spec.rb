require 'rails_helper'

require_relative '../../../../app/services/statistics/player_statistics.rb'

describe 'MapsFailedStatisticTest' do
  it 'counts maps played correctly' do
    player = create(:player)
    create_list(:match_score, 10, player: player)

    expect(PlayerStatistics::MapsPlayedStatistic.new(player).compute).to equal(10)
  end
end
