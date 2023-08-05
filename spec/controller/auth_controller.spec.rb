require 'rails_helper'

RSpec.describe "GET /authorise/osu", type: :request do
  it "correctly processes a new user signup" do
    player = FactoryBot.create(
      :player_with_auth_request,
      id: 1,
      discord_id: 1,
      osu_id: nil,
    )
    auth_request = player.osu_auth_requests.first

    allow(OsuAuthRequest).to receive(:process_code_response).and_return({ id: 1, name: 'test' }.as_json)

    get "/authorise/osu", params: { state: auth_request.nonce, code: "abcd" }

    expect(auth_request).to receive(:process_code_response).with('abcd')
    expect(auth_request).to change { auth_request.resolved }.from(false).to(true)
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
