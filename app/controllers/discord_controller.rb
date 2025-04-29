class DiscordController < ApplicationController
  before_action :authenticate_player!

  def show
    @data = DiscordServer.all

    respond_to do |format|
      format.html
      format.json { render json: @data, status: :ok }
    end
  end

  def update
  end

  def show_server
    params = params.permit(:id)
  end

  def show_exp_leaderboard
    data =
      DiscordExp
        .where(discord_server_id: params[:server_id])
        .order(exp: :desc, player_id: :asc)
        .includes(%i[player])
        .page(params[:page])
        .per(params[:limit])
        .to_json(include: { player: { include: :identities }})

    respond_to do |format|
      format.html do
        @data = data
        render status: :ok
      end

      format.json { render json: data, status: :ok }
    end
  end

  def invite
    link = ENV.fetch("DISCORD_INVITE_LINK", false)

    link ? redirect_to(link) : render(file: "#{Rails.root}/public/404.html", layout: false, status: 404)
  end

  private

  def update_config_params
    params.permit(:discord_server)
  end
end
