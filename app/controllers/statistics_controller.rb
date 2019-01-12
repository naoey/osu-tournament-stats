class StatisticsController < ApplicationController
  def show
    @data = [{
      :playerName => "Xav",
      :accuracy => 0.59,
      :mapsPlayed => 100,
      :mapsWon => 100,
    }]
  end
end
