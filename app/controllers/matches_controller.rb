##
# Handles all match related operations in the application.
class MatchesController < ApplicationController
  def show
    @data = Match.all

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  def add
    begin
      MatchServices::OsuApiParser.new.load_match(add_match_params)

      match = Match.find_by_online_id(add_match_params[:online_id])

      match.added_by = current_player
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
    params.require(:match).permit(:online_id, :name, :tournament_id)
  end
end
