require 'rails_helper'
require 'base64'

RSpec.describe Player do
  logger = SemanticLogger['PlayerSpec']

  mock_discord_user = { id: 1, name: 'test' }.stringify_keys!

  before(:all) do
    @mock_server = create(:discord_server)
  end

  describe "get_osu_verification_link" do
    it "should write the state to cache correctly" do
      expect(Rails.cache).to receive(:write)
        .with(
          "discord_bot/osu_verification_links/#{mock_discord_user["id"]}",
          hash_including({ user: mock_discord_user, guild: @mock_server.as_json }.stringify_keys!),
          expires_in: 5.minutes,
        )
      Player.get_osu_verification_link(mock_discord_user, @mock_server.as_json)
    end
  end

  describe 'from_bot_link' do
    it "should correctly handle a completely fresh user" do

    end

    it "should correctly handle a user who has a discord auth but no osu auth" do

    end

    it "should correctly handle a user who has an osu auth but no discord auth" do

    end

    it "should correctly handle a user who has both discord and osu auths" do

    end

    it "should correctly merge into the osu player when discord and osu auths exist but belong to different players with different exp" do
      osu_id = 69

      discord_player = create(:player, identities: []) do |p|
        p.discord_exp = [create(:discord_exp, discord_server: @mock_server, player: p)]
        p.identities.build(provider: :discord, uid: mock_discord_user["id"], uname: 'test')
        p.save!
      end

      osu_player = create(:player, identities: []) do |p|
        p.discord_exp = [create(:discord_exp, discord_server: @mock_server, player: p)]
        p.identities.build(provider: :osu, uid: osu_id, uname: 'test')
        p.save!
      end

      link = Player.get_osu_verification_link(
        mock_discord_user,
        { id: @mock_server.id, name: 'test_server' }
      )

      url = URI.parse(link)
      params = CGI.parse(url.query)
      _, guid = Base64.decode64(params['s'].first).split('|')

      logger.info("Mocking callback for GUID", { guid: })

      omniauth = double("OmniAuth::Strategies::Osu", uid: osu_id)

      allow(Rails.cache).to receive(:read)
        .with("discord_bot/osu_verification_links/#{mock_discord_user["id"]}")
        .and_return({ guild: @mock_server.as_json, user: mock_discord_user, guid: }.stringify_keys!)

      Player.from_bot_link(omniauth, params['s'].first)

      expect_any_instance_of(DiscordExp).to receive(:merge)
        .with(discord_player.discord_exp)
      expect(osu_player.identities.exists?(provider: :discord)).to eq(true)
      expect(Player.exists?(id: discord_player.id)).to eq(false)
    end
  end
end
