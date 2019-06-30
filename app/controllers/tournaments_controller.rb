##
# Manages all tournament related actions in the application.
class TournamentsController < ApplicationController
  def show
    @data = Tournament
      .where('name LIKE ?', "%#{params[:name]}%")
      .all
      .map do |t|
        {
          id: t.id,
          name: t.name,
          host_player: MatchServices::OsuApiParser.new.get_or_load_player(t.host_player_id),
          match_count: Match.where(tournament_id: t.id).count(:all),
        }
      end
  end

  def show_tournament
  end

  def delete
    tournament = Tournament.find(edit_params[:id])
    if tournament.delete
      render json: nil, status: :ok
    else
      render json: tournament.errors, status: :unprocessable_entity
    end
  end

  def add
    @tournament = Tournament.new(add_params)

    if @tournament.save!
      return render json: @tournament, status: :ok
    else
      return render json: { errors: @tournament.errors, status: :bad_request }
    end
  end

  def edit
  end

  private

  def edit_params
    params.require[:tournament].permit(:name, :host)
  end

  def add_params
    params.require[:tournament].permit(:name, :host_player_id, :start_date, :end_date)
  end
end
