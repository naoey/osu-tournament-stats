require 'rails_helper'

require_relative '../../../../app/services/statistics/tournament_statistics.rb'

describe 'TournamentPlayerStatisticTest' do
  context 'when invalid initialisation' do
    it 'throws error for initialisation with nil Player' do
      expect { TournamentStatistics::TournamentPlayerStatistic.new(build(:player), nil) }.to raise_error(ArgumentError)
    end

    it 'throws error for initialisation with non-Player type argument' do
      expect { TournamentStatistics::TournamentPlayerStatistic.new(build(:player), build(:player)) }.to raise_error(ArgumentError)
    end
  end

  context 'when valid initialisation' do
    it 'builds without errors' do
      expect { TournamentStatistics::TournamentPlayerStatistic.new(build(:player), build(:tournament)) }.not_to raise_error
    end
  end
end
