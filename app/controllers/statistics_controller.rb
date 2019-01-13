class StatisticsController < ApplicationController
  def show_matches
    @data = Match.all.map {|match|
      {
        :round_name => match.match_name,
        :winner => match.match_scores.map {|s| JSON.parse(s.raw_json)}.max_by {|s| s["score"].to_i}["user_id"].to_i,
        :red_player => {
          :id => match.player_red.id,
          :name => match.player_red.name,
        },
        :blue_player => {
          :id => match.player_blue.id,
          :name => match.player_blue.name,
        },
        :timestamp => match.match_timestamp.to_time.iso8601,
        :id => match.id,
      }
    }
  end
end
