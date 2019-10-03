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

    respond_to do |format|
      format.html
      format.json { render json: @tournament, status: :ok }
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

    tournament.host_player = ApiServices::OsuApi.new.get_or_load_player(current_player.id)

    return render json: create_tournament_json(tournament), status: :ok if tournament.save

    render json: { errors: tournament.errors, status: :bad_request }
  end

  private

  def add_params
    params.require(:tournament).permit(:name, :start_date, :end_date)
  end

  def create_tournament_json(tournament)
    {
      id: tournament.id,
      name: tournament.name,
      host_player: create_player_json(tournament.host_player),
      match_count: Match.where(tournament_id: tournament.id).count(:all),
      start_date: tournament.start_date,
      end_date: tournament.end_date,
      created_at: tournament.created_at,
      updated_at: tournament.updated_at,
    }
  end

  def create_player_json(player)
    return nil if player.nil?

    player.as_json.except('updated_at')
  end
end
