class StatisticsController < ApplicationController
  def show_matches
    @data = Match.all.map {|match|
      {
        :round_name => match.round_name,
        :winner => match.winner,
        :online_id => match.online_id,
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
    player_scores = MatchScore.where(:player => player)
    player_accuracies = player_scores.map(&method(:accuracy?))
    {
      :name => player.name,
      :online_id => player.id,
      :matches_played => Match.count_by_sql("SELECT COUNT(*) FROM \"matches\" WHERE \"matches\".\"player_red\" = #{player.id} OR \"matches\".\"player_blue\" = #{player.id}"),
      :matches_won => Match.where(:winner => player.id).count,
      :maps_played => player_scores.count,
      :maps_won => maps_won?(player),
      :best_accuracy => (player_accuracies.max * 100.0).round(2),
      :average_accuracy => (player_accuracies.reduce(0, :+) / player_accuracies.count.to_f * 100.0).round(2),
      :perfect_count => player_scores.where(:perfect => true).count,
      :average_misses => player_scores.average(:count_miss).round(2),
      :total_misses => player_scores.sum(:count_miss),
      :average_score => player_scores.average(:score).round(2),
      :total_score => player_scores.sum(:score)
    }
  end

  def maps_won?(player)
    match_ids = MatchScore.where(:player_id => player.id).map(&:match_id)

    puts "Evaluating player #{player.id}"
    MatchScore.where(:match_id => match_ids).all.to_a.group_by(&:beatmap_id).values.reduce(0) {|sum,m| pp m; m.max_by(&:score).player_id == player.id ? sum + 1 : 0}
  end

  def average_misses?(player)
  end

  def accuracy?(score)
    # https://osu.ppy.sh/help/wiki/Accuracy
    ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300)) / (300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)).to_f
  end
end
