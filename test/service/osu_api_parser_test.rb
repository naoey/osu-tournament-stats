require 'test/unit'

class OsuApiParserTest < Test::Unit::TestCase
  # get_or_load_beatmap tests
  def test_get_or_load_beatmap_non_existent
    stub_request(:get, /osu\.ppy\.sh\/api\/get_beatmaps/)
      .to_return(status: 200, body: [].to_s)
      .times(1)

    e = assert_raise(OsuApiParserExceptions::BeatmapLoadFailedError) {
      MatchServices::OsuApiParser.new.get_or_load_beatmap(12345)
    }
    assert_equal("Beatmap with id 12345 not found on osu! server", e.message)
    assert_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_beatmaps/, times: 1)
  end

  def test_get_or_load_beatmaps_already_exists
    b = MatchServices::OsuApiParser.new.get_or_load_beatmap(1428999)

    assert_not_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_beatmaps/)
    assert_instance_of(Beatmap, b)
  end

  def test_get_or_load_beatmap_new
    Beatmap.delete(666)

    stub_request(:get, /osu\.ppy\.sh\/api\/get_beatmaps/)
      .with(query: hash_including({
        b: "666"
      }))
      .to_return(status: 200, body: [{
        artist: "naoey",
        title: "Fake Test Beatmap",
        beatmap_id: "666",
        version: "naoey's fake",
        difficultyrating: "6.66",
        max_combo: 6666
      }].to_json.to_s)
      .times(1)

    count_before = Beatmap.count

    b = MatchServices::OsuApiParser.new.get_or_load_beatmap(666)

    assert_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_beatmaps/, times: 1)
    assert_equal(count_before + 1, Beatmap.count)

    # clean up test beatmap
    b.delete
  end

  # get_or_load_player tests
  def test_get_or_load_player_non_existent
    stub_request(:get, /osu\.ppy\.sh\/api\/get_user/)
      .to_return(status: 200, body: [].to_s)
      .times(1)

    e = assert_raise(OsuApiParserExceptions::PlayerLoadFailedError) {
      MatchServices::OsuApiParser.new.get_or_load_player(12345)
    }
    assert_equal("Player 12345 not found on osu! server", e.message)
    assert_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_user/, times: 1)
  end

  def test_get_or_load_player_already_exists_id
    p = MatchServices::OsuApiParser.new.get_or_load_player(1788022)

    assert_not_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_user/)
    assert_instance_of(Player, p)
  end

  def test_get_or_load_player_already_exists_username
    p = MatchServices::OsuApiParser.new.get_or_load_player("Meet")

    assert_not_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_user/)
    assert_instance_of(Player, p)
  end

  def test_get_or_load_player_new_id
    Player.delete(22)

    stub_request(:get, /osu\.ppy\.sh\/api\/get_user/)
      .with(query: hash_including({
        u: "22"
      }))
      .to_return(status: 200, body: [{
        username: "naoey",
        user_id: "22",
      }].to_json.to_s)
      .times(1)

    count_before = Player.count

    p = MatchServices::OsuApiParser.new.get_or_load_player(22)

    assert_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_user/, times: 1)
    assert_equal(count_before + 1, Player.count)

    # clean up test player
    p.delete
  end

  def test_get_or_load_player_new_id
    Player.delete(33)

    stub_request(:get, /osu\.ppy\.sh\/api\/get_user/)
      .with(query: hash_including({
        u: "nitr0f"
      }))
      .to_return(status: 200, body: [{
        username: "nitr0f",
        user_id: "33",
      }].to_json.to_s)
      .times(1)

    count_before = Player.count

    p = MatchServices::OsuApiParser.new.get_or_load_player("nitr0f")

    assert_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_user/, times: 1)
    assert_equal(count_before + 1, Player.count)

    # clean up test player
    p.delete
  end

  # load_match tests
  def test_load_match_existing
    e = assert_raises(OsuApiParserExceptions::MatchExistsError) {
      MatchServices::OsuApiParser.new.load_match(osu_match_id: 48831639, round_name: "Test Match")
    }
    assert_equal("Match 48831639 already exists in database", e.message)
    assert_not_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_match/)
  end

  def test_load_match_empty_response
    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200)
      .times(1)

    e = assert_raises(OsuApiParserExceptions::MatchParseFailedError) {
      MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")
    }
    assert_equal("Failed to load match from osu! API", e.message)
    assert_requested(:get, /https:\/\/osu\.ppy\.sh\/api\/get_match/, times: 1)
  end

  def test_load_match_invalid_match_name
    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200, body: {
        match: {
          name: "This is not a valid tournament match name"
        }
      }.to_json.to_s)
      .times(1)

    e = assert_raises(OsuApiParserExceptions::MatchParseFailedError) {
      MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")
    }
    assert_equal("Match name doesn't match tournament format!", e.message)
    assert_requested(:get, /osu\.ppy\.sh\/api\/get_match/, times: 1)
  end

  def test_load_match_throw_error_indeterminate_winner_no_pass
    Match.where(:online_id => 99).destroy_all

    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200, body: {
        match: {
          name: "OIWT: Potla vs. Meet",
          match_id: "99",
          start_time: DateTime.now.to_s
        },
        games: [{
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "1428999",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 0, 0, 50000),
            create_game_score(2003720, 0, 0, 1, 60000),
            create_referee_score(),
          ]
        }, {
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "766602",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 0, 0, 60000),
            create_game_score(2003720, 0, 0, 1, 50000),
            create_referee_score(),
          ]
        }]
      }.to_json.to_s)
      .times(1)

    e = assert_raises(OsuApiParserExceptions::MatchParseFailedError) {
      MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")
    }
    assert_equal("Impossible situation where map has no passes at all", e.message)
    assert_requested(:get, /osu\.ppy\.sh\/api\/get_match/, times: 1)
  end

  def test_load_match_throw_error_indeterminate_winner
    Match.where(:online_id => 99).destroy_all

    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200, body: {
        match: {
          name: "OIWT: Potla vs. Meet",
          match_id: "99",
          start_time: DateTime.now.to_s
        },
        games: [{
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "1428999",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 50000),
            create_game_score(2003720, 0, 1, 1, 60000),
            create_referee_score(),
          ]
        }, {
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "766602",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 60000),
            create_game_score(2003720, 0, 1, 1, 50000),
            create_referee_score(),
          ]
        }]
      }.to_json.to_s)
      .times(1)

    e = assert_raises(OsuApiParserExceptions::MatchParseFailedError) {
      MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")
    }
    assert_equal("Impossible situation where red and blue have equal wins in a match", e.message)
    assert_requested(:get, /osu\.ppy\.sh\/api\/get_match/, times: 1)
  end

  def test_load_match_throw_error_referee_winner
    Match.where(:online_id => 99).destroy_all

    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200, body: {
        match: {
          name: "OIWT: Potla vs. Meet",
          match_id: "99",
          start_time: DateTime.now.to_s
        },
        games: [{
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "1428999",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 50000),
            create_game_score(2003720, 0, 1, 1, 60000),
            create_game_score(7753207, 0, 1, 2, 80000),
          ]
        }, {
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "766602",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 60000),
            create_game_score(2003720, 0, 1, 1, 50000),
            create_game_score(7753207, 0, 1, 2, 80000),
          ]
        }]
      }.to_json.to_s)
      .times(1)

    e = assert_raises(OsuApiParserExceptions::MatchParseFailedError) {
      MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")
    }
    assert_equal("Impossible situation where winner of map is not red or blue player", e.message)
    assert_requested(:get, /osu\.ppy\.sh\/api\/get_match/, times: 1)
  end

  def test_load_match_replayed_maps
    Match.where(:online_id => 99).destroy_all

    mock_response = {
      match: {
        name: "OIWT: Potla vs. Meet",
        match_id: "99",
        start_time: DateTime.now.to_s
      },
      games: [{
        team_type: "2",
        scoring_type: "3",
        beatmap_id: "1428999",
        game_id: rand(9999999).to_s,
        start_time: (DateTime.now - 25.minutes).to_s,
        scores: [
          create_game_score(1788022, 0, 1, 0, 50000),
          create_game_score(2003720, 0, 1, 1, 60000),
          create_referee_score(),
        ]
      }, {
        team_type: "2",
        scoring_type: "3",
        beatmap_id: "1428999",
        game_id: rand(9999999).to_s,
        start_time: (DateTime.now - 20.minutes).to_s,
        scores: [
          create_game_score(1788022, 0, 1, 0, 50000),
          create_game_score(2003720, 0, 1, 1, 60000),
          create_referee_score(),
        ]
      }, {
        team_type: "2",
        scoring_type: "3",
        beatmap_id: "766602",
        game_id: rand(9999999).to_s,
        start_time: (DateTime.now - 10.minutes).to_s,
        scores: [
          create_game_score(1788022, 0, 1, 0, 60000),
          create_game_score(2003720, 0, 1, 1, 50000),
          create_referee_score(),
        ]
      }, {
        team_type: "2",
        scoring_type: "3",
        beatmap_id: "1262906",
        game_id: rand(9999999).to_s,
        start_time: (DateTime.now - 5.minutes).to_s,
        scores: [
          create_game_score(1788022, 0, 1, 0, 60000),
          create_game_score(2003720, 0, 1, 1, 50000),
          create_referee_score(),
        ]
      }]
    }

    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200, body: mock_response.to_json.to_s)
      .times(1)

    count_before = Match.count
    count_match_score_before = MatchScore.count

    MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")

    assert_requested(:get, /osu\.ppy\.sh\/api\/get_match/, times: 1)
    assert_equal(count_before + 1, Match.count)
    # 2 players * 3 maps in the test data = 6 scores should have been added
    assert_equal(count_match_score_before + (2 * 3), MatchScore.count)

    parsed_match_scores = MatchScore.where(:match_id => Match.find_by_online_id(99).id)

    parsed_match_scores.each do |s|
      # First game in mock data is replayed, so the first one should not have been saved in favour of saving the later game
      assert_not_equal(s.online_game_id.to_s, mock_response[:games][0][:game_id])
    end

    Match.where(:online_id => 99).destroy_all
  end

  def test_load_match
    Match.where(:online_id => 99).destroy_all

    stub_request(:get, /osu\.ppy\.sh\/api\/get_match/)
      .with(query: hash_including({
        mp: "99"
      }))
      .to_return(status: 200, body: {
        match: {
          name: "OIWT: Potla vs. Meet",
          match_id: "99",
          start_time: DateTime.now.to_s
        },
        games: [{
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "1428999",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 50000),
            create_game_score(2003720, 0, 1, 1, 60000),
            create_referee_score(),
          ]
        }, {
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "766602",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 10.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 60000),
            create_game_score(2003720, 0, 1, 1, 50000),
            create_referee_score(),
          ]
        }, {
          team_type: "2",
          scoring_type: "3",
          beatmap_id: "1262906",
          game_id: rand(9999999).to_s,
          start_time: (DateTime.now - 15.minutes).to_s,
          scores: [
            create_game_score(1788022, 0, 1, 0, 60000),
            create_game_score(2003720, 0, 1, 1, 50000),
            create_referee_score(),
          ]
        }]
      }.to_json.to_s)
      .times(1)

    count_before = Match.count
    count_match_score_before = MatchScore.count

    MatchServices::OsuApiParser.new.load_match(osu_match_id: 99, round_name: "Test Match")

    assert_requested(:get, /osu\.ppy\.sh\/api\/get_match/, times: 1)
    assert_equal(count_before + 1, Match.count)
    # 2 players * 3 maps in the test data = 6 scores should have been added
    assert_equal(count_match_score_before + (2 * 3), MatchScore.count)

    Match.where(:online_id => 99).destroy_all
  end

  private
  def create_game_score(player_id, perfect, pass, slot, score = rand(999999))
    {
      user_id: player_id.to_s,
      score: score.to_s,
      slot: slot.to_s,
      maxcombo: rand(9999).to_s,
      count50: rand(1000).to_s,
      count100: rand(1000).to_s,
      count300: rand(1000).to_s,
      countgeki: rand(1000).to_s,
      count_katu: rand(1000).to_s,
      countmiss: rand(1000).to_s,
      perfect: perfect.to_s,
      pass: pass.to_s,
    }
  end

  def create_referee_score()
    {
      user_id: "7753207",
      score: "0",
      maxcombo: "0",
      count50: "0",
      count100: "0",
      count300: "0",
      countgeki: "0",
      count_katu: "0",
      countmiss: "99999",
      perfect: "0",
      pass: "0",
    }
  end
end
