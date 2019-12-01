class StatisticsController < ApplicationController
  def show_all_players
    @data = []

    Player.all.each do |player|
      @data.push(service.get_player_stats(player))
    end

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  def show_tournament
    if params[:id].nil?
      return respond_to do |f|
        f.json { render nothing: true, status: :bad_request }
      end
    end

    @data = service.get_all_player_stats_for_tournament(params[:id])

    respond_to do |f|
      f.json { render json: @data, status: :ok }
    end
  end

  private

  def score_accuracy(score)
    # https://osu.ppy.sh/help/wiki/Accuracy
    ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300)) / (300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300))
      .to_f
  end

  def service
    StatisticsServices::PlayerStatistics.new
  end
end
