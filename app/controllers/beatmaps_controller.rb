class BeatmapsController < ApplicationController
  def search
    return render json: nil, status: :bad_request if beatmap_params[:ids].nil? || !beatmap_params[:ids].is_a?(Array)

    beatmaps = Beatmap.where(id: [beatmap_params[:ids]]).all

    render json: beatmaps || [], status: :ok
  end

  private

  def beatmap_params
    params.permit(ids: [])
  end
end
