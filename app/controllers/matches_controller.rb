##
# Handles all match related operations in the application.
class MatchesController < ApplicationController
  def show
    @data = Match.all.where(tournament_id: params[:tournament_id])

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  def show_match
    begin
      @data = StatisticsServices::PlayerStatistics.new.get_all_player_stats_for_match(params[:id])
    rescue GenericExceptions::NotFoundError
      respond_to do |format|
        format.html { render status: :not_found }
      end
    end

    respond_to do |format|
      format.html
    end
  end

  def add
    begin
      ApiServices::OsuApi.new.load_match(add_match_params)

      match = Match.find_by_online_id(add_match_params[:online_id])

      match.save

      render json: match, status: :ok
    rescue OsuApiParserExceptions::MatchExistsError
      render json: { error: "Match with osu! multiplayer ID #{add_match_params[:online_id]} already exists", status: :conflict }
    rescue OsuApiParserExceptions::MatchLoadFailedError
      render json: { error: 'Failed to retrieve match from osu! API', status: :not_found }
    rescue OsuApiParserExceptions::MatchParseFailedError
      render json: { error: 'An error occurred while parsing the match', status: :server_error }
    end
  end

  def delete
    Match.find(params[:id]).destroy
  end

  private

  def add_match_params
    params.require(:match).permit(:osu_match_id, :round_name, :tournament_id, :discard_list)
  end
end
