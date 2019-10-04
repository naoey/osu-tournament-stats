require 'test/unit'

class OsuApiTest < Test::Unit::TestCase
  # get_or_load_beatmap tests
  def test_get_or_load_beatmap_non_existent
    stub_request(:get, %r{osu\.ppy\.sh/api/get_beatmaps})
      .to_return(status: 200, body: [].to_s)
      .times(1)

    e = assert_raise(OsuApiParserExceptions::BeatmapLoadFailedError) do
      ApiServices::OsuApi.new.get_or_load_beatmap(12_345)
    end

    assert_equal('Beatmap with id 12345 not found on osu! server', e.message)
    assert_requested(:get, %r{https://osu\.ppy\.sh/api/get_beatmaps}, times: 1)
  end

  def test_get_or_load_beatmaps_already_exists
    b = ApiServices::OsuApi.new.get_or_load_beatmap(1_428_999)

    assert_not_requested(:get, %r{https://osu\.ppy\.sh/api/get_beatmaps})
    assert_instance_of(Beatmap, b)
  end

  def test_get_or_load_beatmap_new
    Beatmap.delete(666)

    stub_request(:get, %r{osu\.ppy\.sh/api/get_beatmaps})
      .with(query: hash_including(
        b: '666'
      ))
      .to_return(status: 200, body: [{
        artist: 'naoey',
        title: 'Fake Test Beatmap',
        beatmap_id: '666',
        version: "naoey's fake",
        difficultyrating: '6.66',
        max_combo: 6666,
      }].to_json.to_s)
      .times(1)

    count_before = Beatmap.count

    b = ApiServices::OsuApi.new.get_or_load_beatmap(666)

    assert_requested(:get, %r{https://osu\.ppy\.sh/api/get_beatmaps}, times: 1)
    assert_equal(count_before + 1, Beatmap.count)

    # clean up test beatmap
    b.delete
  end

  # get_or_load_player tests
  def test_get_or_load_player_non_existent
    stub_request(:get, %r{osu\.ppy\.sh/api/get_user})
      .to_return(status: 200, body: [].to_s)
      .times(1)

    e = assert_raise(OsuApiParserExceptions::PlayerLoadFailedError) do
      ApiServices::OsuApi.new.get_or_load_player(12_345)
    end
    assert_equal('Player 12345 not found on osu! server', e.message)
    assert_requested(:get, %r{https://osu\.ppy\.sh/api/get_user}, times: 1)
  end

  def test_get_or_load_player_already_exists_id
    p = ApiServices::OsuApi.new.get_or_load_player(1_788_022)

    assert_not_requested(:get, %r{https://osu\.ppy\.sh/api/get_user})
    assert_instance_of(Player, p)
  end

  def test_get_or_load_player_already_exists_username
    p = ApiServices::OsuApi.new.get_or_load_player('Meet')

    assert_not_requested(:get, %r{https://osu\.ppy\.sh/api/get_user})
    assert_instance_of(Player, p)
  end

  def test_get_or_load_player_new_id
    Player.delete(22)

    stub_request(:get, %r{osu\.ppy\.sh/api/get_user})
      .with(query: hash_including(
        u: '22'
      ))
      .to_return(status: 200, body: [{
        username: 'naoey',
        user_id: '22',
      }].to_json.to_s)
      .times(1)

    count_before = Player.count

    p = ApiServices::OsuApi.new.get_or_load_player(22)

    assert_requested(:get, %r{https://osu\.ppy\.sh/api/get_user}, times: 1)
    assert_equal(count_before + 1, Player.count)

    # clean up test player
    p.delete
  end

  def test_get_or_load_player_new_id
    Player.delete(33)

    stub_request(:get, %r{osu\.ppy\.sh/api/get_user})
      .with(query: hash_including(
        u: 'nitr0f'
      ))
      .to_return(status: 200, body: [{
        username: 'nitr0f',
        user_id: '33',
      }].to_json.to_s)
      .times(1)

    count_before = Player.count

    p = ApiServices::OsuApi.new.get_or_load_player('nitr0f')

    assert_requested(:get, %r{https://osu\.ppy\.sh/api/get_user}, times: 1)
    assert_equal(count_before + 1, Player.count)

    # clean up test player
    p.delete
  end

  private

  def create_game_score(player_id, perfect, pass, slot, score = rand(999_999))
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

  def create_referee_score
    {
      user_id: '7753207',
      score: '0',
      maxcombo: '0',
      count50: '0',
      count100: '0',
      count300: '0',
      countgeki: '0',
      count_katu: '0',
      countmiss: '99999',
      perfect: '0',
      pass: '0',
    }
  end
end
