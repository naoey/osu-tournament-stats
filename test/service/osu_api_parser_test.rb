require 'test/unit'

class OsuApiParserTest < Test::Unit::TestCase
  # get_or_load_beatmap tests
  def test_get_or_load_beatmap_non_existent
    stub_request(:get, /osu\.ppy\.sh\/api\/get_beatmaps/)
      .to_return(status: 200, body: [].to_s)
      .times(1)

    assert_raise(OsuApiParserExceptions::BeatmapLoadFailedError) {
      MatchServices::OsuApiParser.new.get_or_load_beatmap(12345)
    }
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

    assert_raise(OsuApiParserExceptions::PlayerLoadFailedError) {
      MatchServices::OsuApiParser.new.get_or_load_player(12345)
    }
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
end
