require 'rails_helper'
require 'base64'

RSpec.describe Player do
  logger = SemanticLogger['PlayerSpec']

  mock_discord_user = { id: 1, username: 'test' }.stringify_keys!

  before(:each) do
    DiscordExp.destroy_all
    DiscordServer.destroy_all
    Player.destroy_all

    @mock_server = create(:discord_server)
  end

  def get_state_guid_from_link(link)
    url = URI.parse(link)
    params = CGI.parse(url.query)
    _, guid = Base64.decode64(params['s'].first).split('|')

    return params['s'].first, guid
  end

  def create_omniauth(provider: nil, uid: nil, **args)
    double("OmniAuth::Strategies::Osu", uid:, provider:, **args)
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
    # When registering having never sent a message and hence not having a record in DB
    xit "should correctly handle a completely fresh user" do
      osu_id = 69

      link = Player.get_osu_verification_link(mock_discord_user, @mock_server)

      # User shouldn't be created at this point yet
      expect(PlayerAuth.exists?(uid: mock_discord_user["id"])).to eq(false)

      omniauth = create_omniauth(provider: "osu", uid: osu_id)

      state, guid = get_state_guid_from_link(link)

      allow(Rails.cache).to receive(:read)
        .with("discord_bot/osu_verification_links/#{mock_discord_user["id"]}")
        .and_return({ guild: @mock_server.as_json, user: mock_discord_user, guid: }.stringify_keys!)
      allow(omniauth).to receive(:info)
        .and_return({ username: "test" })

      Player.from_bot_link(omniauth, state)

      expect(PlayerAuth.exists?(uid: osu_id)).to eq(true)
      expect(PlayerAuth.exists?(uid: mock_discord_user["id"])).to eq(true)
    end

    # When registering after having sent some messages, and having only a Discord user in the DB with some exp
    it "should correctly handle a fresh user who has accumulated exp" do
      osu_id = 69

      discord_player = create(:player, identities: []) do |p|
        p.discord_exp = [create(:discord_exp, discord_server: @mock_server, player: p, level: 1, exp: 105, detailed_exp: [5, 100, 105])]
        p.identities.build(provider: :discord, uid: mock_discord_user["id"], uname: 'test')
        p.save!
      end

      link = Player.get_osu_verification_link(
        mock_discord_user,
        { id: @mock_server.id, name: 'test_server' }
      )

      state, guid = get_state_guid_from_link(link)

      logger.info("Mocking callback for GUID", { guid: })

      omniauth = create_omniauth(uid: osu_id, provider: "osu")

      allow(Rails.cache).to receive(:read)
        .with("discord_bot/osu_verification_links/#{mock_discord_user["id"]}")
        .and_return({ guild: @mock_server.as_json, user: mock_discord_user, guid: }.stringify_keys!)
      allow(omniauth).to receive(:info)
        .and_return({ username: "test", country_code: "IN" })

      Player.from_bot_link(omniauth, state)

      final_player = PlayerAuth.find_by_uid(mock_discord_user["id"]).player

      expect(final_player.osu.uid).to eq(osu_id)
      expect(final_player.discord_exp.find_by(discord_server: @mock_server).level).to eq(1)
      expect(final_player.discord_exp.find_by(discord_server: @mock_server).detailed_exp).to eq([5, 100, 105])
      expect { discord_player.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should correctly handle a user who has a discord auth but no osu auth" do
      osu_id = 69

      discord_player = create(:player, identities: []) do |p|
        p.discord_exp = [create(:discord_exp, discord_server: @mock_server, player: p)]
        p.identities.build(provider: :discord, uid: mock_discord_user["id"], uname: 'test')
        p.save!
      end

      link = Player.get_osu_verification_link(
        mock_discord_user,
        { id: @mock_server.id, name: 'test_server' }
      )

      state, guid = get_state_guid_from_link(link)

      logger.info("Mocking callback for GUID", { guid: })

      omniauth = create_omniauth(uid: osu_id, provider: "osu")

      allow(Rails.cache).to receive(:read)
        .with("discord_bot/osu_verification_links/#{mock_discord_user["id"]}")
        .and_return({ guild: @mock_server.as_json, user: mock_discord_user, guid: }.stringify_keys!)
      allow(omniauth).to receive(:info)
        .and_return({ username: "test", country_code: "IN" })

      Player.from_bot_link(omniauth, state)

      final_player = PlayerAuth.find_by_uid(mock_discord_user["id"]).player

      expect(final_player.osu.uid).to eq(osu_id)
      expect { discord_player.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should correctly handle a user who has an osu auth but no discord auth" do
      osu_id = 69
      osu_player = create(:player, identities: []) do |p|
        p.discord_exp = [create(:discord_exp, discord_server: @mock_server, player: p)]
        p.identities.build(provider: :osu, uid: osu_id, uname: 'test')
        p.save!
      end

      link = Player.get_osu_verification_link(
        mock_discord_user,
        { id: @mock_server.id, name: 'test_server' }
      )

      state, guid = get_state_guid_from_link(link)

      logger.info("Mocking callback for GUID", { guid: })

      omniauth = create_omniauth(uid: osu_id, provider: "osu")

      allow(Rails.cache).to receive(:read)
        .with("discord_bot/osu_verification_links/#{mock_discord_user["id"]}")
        .and_return({ guild: @mock_server.as_json, user: mock_discord_user, guid: }.stringify_keys!)
      allow(omniauth).to receive(:info)
        .and_return({ username: "test", country_code: "IN" })

      Player.from_bot_link(omniauth, state)

      expect { osu_player.reload }.not_to raise_error
      expect(osu_player.discord.uid).to eq(mock_discord_user["id"])
    end

    it "should throw an error for a user who has both auths already" do
      osu_id = 69

      player = create(:player, identities: []) do |p|
        p.discord_exp = [create(:discord_exp, discord_server: @mock_server, player: p)]
        p.identities.build(provider: :discord, uid: mock_discord_user["id"], uname: 'test')
        p.identities.build(provider: :osu, uid: osu_id, uname: 'test')
        p.save!
      end

      expect(Rails.cache).not_to receive(:write)
      expect { Player.get_osu_verification_link(
        mock_discord_user,
        { id: @mock_server.id, name: 'test_server' }
      ) }.to raise_error(RuntimeError)
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

      state, guid = get_state_guid_from_link(link)

      logger.info("Mocking callback for GUID", { guid: })

      allow(Rails.cache).to receive(:read)
        .with("discord_bot/osu_verification_links/#{mock_discord_user["id"]}")
        .and_return({ guild: @mock_server.as_json, user: mock_discord_user, guid: }.stringify_keys!)

      omniauth = create_omniauth(uid: osu_id, provider: "osu")

      expect_any_instance_of(DiscordExp).to receive(:merge)
        .with(
          discord_player.discord_exp.find_by(
            player_id: discord_player.id, discord_server_id: @mock_server.id
          )
        )

      Player.from_bot_link(omniauth, state)

      expect(osu_player.identities.exists?(provider: :discord)).to eq(true)
      expect(Player.exists?(id: discord_player.id)).to eq(false)
    end
  end
end
