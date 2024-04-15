class StatisticsController < ApplicationController
  def show_all_players
    @data = []

    Player.all.each { |player| @data.push(service.get_player_stats(player)) }

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  def show_tournament
    return respond_to { |f| f.json { render nothing: true, status: :bad_request } } if params[:id].nil?

    @data = service.get_all_player_stats_for_tournament(params[:id])

    respond_to { |f| f.json { render json: @data, status: :ok } }
  end

  def show_match
    return respond_to { |f| f.json { render nothing: true, status: :bad_request } } if params[:id].nil?

    @data = service.get_all_player_stats_for_match(params[:id], params[:round_name])

    respond_to { |f| f.json { render json: @data, status: :ok } }
  end

  private

  def score_accuracy(score)
    # https://osu.ppy.sh/help/wiki/Accuracy
    ((50 * score.count_50) + (100 * score.count_100) + (300 * score.count_300)) /
      (300 * (score.count_miss + score.count_50 + score.count_100 + score.count_300)).to_f
  end

  def service
    StatisticsServices::PlayerStatistics_Legacy.new
  end
end
