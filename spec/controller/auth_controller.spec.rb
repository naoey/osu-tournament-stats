require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe "POST /authorise/osu" do
    it "correctly processes a new user signup" do
      player = FactoryBot.create(
        :player_with_auth_request,
        id: 1,
        discord_id: 1,
        osu_id: nil,
      )
      auth_request = player.osu_auth_requests.first

      allow(auth_request).to receive(:process_code_response).and_return({ id: 1, name: 'test' }.as_json)

      expect { get "/authorise/osu", params: { state: auth_request.nonce, code: "abcd" } }
        .to change { auth_request.resolved }.from(0).to(1)
        .and change { player.name }.from(player.name).to("test")
        .and change { player.osu_id }.from(nil).to(1)
    end

    it "correctly updates an existing osu! user to a new discord id" do

    end

    it "correctly prevents linking the same osu! id to multiple discord ids" do

    end

    it "correctly bans a new discord account trying to register with a previously banned osu! account" do

    end
  end
end
