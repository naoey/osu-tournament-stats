##
# Manages all tournament related actions in the application.
class TournamentsController < ApplicationController
  before_action :authenticate_player!, except: %i[show show_tournament]

  def show
    @data = Tournament
      .where('name LIKE ?', "%#{params[:name]}%")
      .all
      .map(&method(:create_tournament_json))

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  def show_tournament
    @tournament = create_tournament_json(Tournament.find_by_id(params[:id]))
    @matches = Match
      .where(tournament_id: params[:id])
      .all
      .as_json
      .map do |m|
        m.except('api_json')
      end

    respond_to do |format|
      format.html
      format.json { render json: { tournament: @tournament, matches: @matches }, status: :ok }
    end
  end

  def delete
    tournament = Tournament.find(params[:id])

    if tournament.nil?
      render json: nil, status: :not_found
    elsif tournament.delete
      render json: nil, status: :ok
    else
      render json: tournament.errors, status: :unprocessable_entity
    end
  end

  def add
    tournament = Tournament.new(add_params)

    tournament.host_player = MatchServices::OsuApiParser.new.get_or_load_player(current_player.id)

    if tournament.save
      return render json: create_tournament_json(tournament), status: :ok
    else
      return render json: { errors: tournament.errors, status: :bad_request }
    end
  end

  private

  def add_params
    params.require(:tournament).permit(:name, :start_date, :end_date)
  end

  # TODO: these should probably be moved into MatchServices
  def create_tournament_json(tournament)
    {
      id: tournament.id,
      name: tournament.name,
      host_player: create_player_json(tournament.host_player),
      match_count: Match.where(tournament_id: tournament.id).count(:all),
      start_date: tournament.start_date,
      end_date: tournament.end_date,
    }
  end

  def create_player_json(player)
    if player == nil
      return nil
    end

    player.as_json.except('updated_at')
  end
end
