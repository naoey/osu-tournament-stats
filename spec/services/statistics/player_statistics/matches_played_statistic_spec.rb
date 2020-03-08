require 'rails_helper'

describe 'MatchesPlayedStatistic' do
  context 'when invalid initialisation'
    it 'throws error' do
      expect { PlayerStatistics::MatchesPlayedStatistic.new(nil).compute }.to raise_error(ArgumentError)
    end

  context 'when valid intitialisation' do
    before do

    end
  end
end
