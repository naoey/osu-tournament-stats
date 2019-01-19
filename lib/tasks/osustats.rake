require 'net/http'
require 'net/https'
require 'json'
require 'date'
require 'pp'

@typo_list = YAML.load_file(Rails.root.join('config', 'player_name_typo_list.yml'))

puts "Loaded typo list"
pp @typo_list

def load_player(username)
  puts "Fetching details for user #{username} from API"

  if @typo_list.key?(username)
    puts "Using name from typo fix list #{username} => #{@typo_list[username]}"
    @correct_username = @typo_list[username]
  else
    @correct_username = username
  end

  player = Player.find_by_name(@correct_username)

  if player != nil
    return player
  end

  http = Net::HTTP.new("osu.ppy.sh", 443)
  http.use_ssl = true

  resp = http.get("/api/get_user?k=#{ENV["OSU_API_KEY"]}&u=#{@correct_username}")

  json = JSON.parse(resp.body)

  if json.length == 0
    raise Exceptions::PlayerNotFoundError
  end

  api_player = json[0]

  player = Player.create({
    :name => api_player["username"],
    :id => api_player["user_id"].to_i
  })

  if player.save
    player
  else
    raise Exceptions::PlayerNotFoundError
  end
end

def load_beatmap(beatmap_id)
  beatmap = Beatmap.find_by_online_id(beatmap_id)

  if beatmap != nil
    return beatmap
  end

  http = Net::HTTP.new("osu.ppy.sh", 443)
  http.use_ssl = true

  puts "Fetching details for beatmap #{beatmap_id} from API"

  resp = http.get("/api/get_beatmaps?k=#{ENV["OSU_API_KEY"]}&b=#{beatmap_id}")

  api_beatmap = JSON.parse(resp.body)[0]

  beatmap = Beatmap.create({
    :name => "#{api_beatmap["artist"]} - #{api_beatmap["title"]}",
    :online_id => api_beatmap["beatmap_id"].to_i,
    :difficulty_name => api_beatmap["version"],
    :star_difficulty => api_beatmap["difficultyrating"].to_f,
    :max_combo => api_beatmap["max_combo"].to_i
  })

  if beatmap.save
    beatmap
  else
    raise Exceptions::BeatmapNotFoundError
  end
end

def parse_match_games(games, match)
  match_games = games.select do |game|
    game["team_type"] == "2" && game["scoring_type"] == "3" && game["scores"].length == 3
  end

  puts "Parsing #{match_games.length} match games"

  match_games.each do |game|
    puts "Parsing game..."

    blue_player_score = game["scores"].find { |score| score["slot"] == "0" }
    red_player_score = game["scores"].find { |score| score["slot"] == "1" }

    load_beatmap game["beatmap_id"].to_i

    red_score = MatchScore.create({
      :match_id => match.id,
      :beatmap_id => game["beatmap_id"].to_i,
      :online_game_id => game["game_id"].to_i,
      :player_id => red_player_score["user_id"].to_i,
      :score => red_player_score["score"].to_i,
      :max_combo => red_player_score["maxcombo"].to_i,
      :count_50 => red_player_score["count50"].to_i,
      :count_100 => red_player_score["count100"].to_i,
      :count_300 => red_player_score["count300"].to_i,
      :count_geki => red_player_score["countgeki"].to_i,
      :count_katu => red_player_score["count_katu"].to_i,
      :count_miss => red_player_score["countmiss"].to_i,
      :perfect => red_player_score["perfect"] == "1",
      :pass => red_player_score["pass"] == "1",
    })

    puts "Red player score save: #{red_score.save}"

    blue_score = MatchScore.create({
      :match_id => match.id,
      :beatmap_id => game["beatmap_id"].to_i,
      :online_game_id => game["game_id"].to_i,
      :player_id => blue_player_score["user_id"].to_i,
      :score => blue_player_score["score"].to_i,
      :max_combo => blue_player_score["maxcombo"].to_i,
      :count_50 => blue_player_score["count50"].to_i,
      :count_100 => blue_player_score["count100"].to_i,
      :count_300 => blue_player_score["count300"].to_i,
      :count_geki => blue_player_score["countgeki"].to_i,
      :count_katu => blue_player_score["count_katu"].to_i,
      :count_miss => blue_player_score["countmiss"].to_i,
      :perfect => blue_player_score["perfect"] == "1",
      :pass => blue_player_score["pass"] == "1",
    })

    puts "Blue player score save: #{blue_score.save}"
  end

  # Every valid tournament map in a match must have recorded two players' scores otherwise the match didn't parse properly
  matches_in_db = MatchScore.where(:match_id => match.id).length
  if matches_in_db != match_games.length * 2
    puts "Match parse failed. Found #{matches_in_db} scores parsed, expected #{match_games.length * 2}"
    raise Exceptions::MatchParseFailedError
  end
end

def parse_match(match, raw, round_name)
  players = match["match"]["name"].split(/OIWT[\s(:\s)]/)[1].split(/\svs.?\s/)

  @player_blue = load_player players[0].tr(" ()", "")
  @player_red = load_player players[1].tr(" ()", "")

  db_match = Match.create({
    :online_id => match["match"]["match_id"],
    :round_name => round_name,
    :match_timestamp => DateTime.parse(match["match"]["start_time"]),
    :api_json => raw,
    :player_blue => @player_blue,
    :player_red => @player_red
  })

  db_match.save

  parse_match_games match["games"], db_match

  db_match.winner = db_match.match_scores.max_by(&:score).player.id
  db_match.save
end

namespace :osustats do
  desc "Add a new match to the stats tracking by the osu! multiplayer match ID"
  task :add_match, [:match_id, :round_name] => [:environment] do |task, args|
    puts "Fetch details for match id #{args[:match_id]} from osu! API"

    http = Net::HTTP.new("osu.ppy.sh", 443)
    http.use_ssl = true

    resp = http.get("/api/get_match?k=#{ENV["OSU_API_KEY"]}&mp=#{args[:match_id]}")

    abort "Match #{args[:match_id]} already exists in database" unless Match.find_by_online_id(args[:match_id]) == nil

    ActiveRecord::Base.transaction do
      begin
        parse_match(JSON.parse(resp.body), resp.body, args[:round_name])
      rescue StandardError => e
        puts "Failed to parse match", e
        puts e.backtrace.join("\n")
        raise ActiveRecord::Rollback
      end
    end
  end
end
