class StatisticsController < ApplicationController
  def show_matches
    @data = Match.all.map {|match|
      {
        :round_name => match.round_name,
        :winner => match.winner,
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

  def show_all_players
    @data = Player.all.map(&method(:transform_player))
  end

  private
  def transform_player(player)
    {
      :name => player.name,
      :online_id => player.id,
      :matches_played => Match.count_by_sql("SELECT COUNT(*) FROM \"matches\" WHERE \"matches\".\"player_red\" = #{player.id} OR \"matches\".\"player_blue\" = #{player.id}"),
      :matches_won => Match.where(:winner => player.id).count,
      :maps_played => MatchScore.where(:player => player.id).count,
      :maps_won => MatchScore.all.to_a.group_by(&:beatmap_id).values.reduce(0) {|sum,x| x.max_by(&:score).player_id == player.id ? sum + 1 : 0},
    }
  end
end
