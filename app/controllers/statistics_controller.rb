class StatisticsController < ApplicationController
  def show
    @data = Match.all.map { |match|
      {
          :name => "#{match.match_name} - #{match.player_red.name} vs #{match.player_blue.name}",
          :timestamp => match.match_timestamp.to_time.iso8601,
          :id => match.id,
      }
    }
  end

  def show_match
    @match_scores = MatchScore.where(:match_id => params[:id])
  end
end
