class TournamentsController < ApplicationController
  def show
    @data = Tournament
      .where('name LIKE ?', "%#{params[:name]}%")
      .all
      .map { |t|
        {
          id: t.id,
          name: t.name,
          host_player: MatchServices::OsuApiParser.new.get_or_load_player(t.host_player_id),
          match_count: Match.where(tournament_id: t.id).count(:all),
        }
      }
  end

  def delete
  end

  def edit
  end
end
