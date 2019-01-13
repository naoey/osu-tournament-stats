require 'net/http'
require 'net/https'
require 'json'
require 'date'
require 'pp'

@typo_list = YAML.load_file(Rails.root.join('config', 'player_name_typo_list.yml'))

puts "Loaded typo list"
pp @typo_list

def load_api_player(username)
  http = Net::HTTP.new("osu.ppy.sh", 443)
  http.use_ssl = true

  puts "Fetching details for user #{username} from API"

  if @typo_list.key?(username)
    puts "Using name from typo fix list #{username} => #{@typo_list[username]}"
    @correct_username = @typo_list[username]
  else
    @correct_username = username
  end

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

def load_api_beatmap(beatmap_id)
  http = Net::HTTP.new("osu.ppy.sh", 443)
  http.use_ssl = true

  puts "Fetching details for beatmap #{beatmap_id} from API"

  resp = http.get("/api/get_beatmaps?k=#{ENV["OSU_API_KEY"]}&b=#{beatmap_id}")

  api_beatmap = JSON.parse(resp.body)[0]

  beatmap = Beatmap.create({
    :name => "#{api_beatmap["artist"]} - #{api_beatmap["title"]}",
    :online_id => api_beatmap["beatmap_id"].to_i,
    :difficulty_name => api_beatmap["version"],
    :star_difficulty => api_beatmap["difficultyrating"].to_f
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
    pp game

    red_player_score = game["scores"].find { |score| score["slot"] == "0" }
    blue_player_score = game["scores"].find { |score| score["slot"] == "1" }

    if Beatmap.find_by_online_id(game["beatmap_id"].to_i) == nil
      load_api_beatmap game["beatmap_id"]
    end

    red_score = MatchScore.create({
      :match_id => match.id,
      :player_id => red_player_score["user_id"].to_i,
      :beatmap_id => game["beatmap_id"].to_i,
      :raw_json => red_player_score.to_json,
      :online_game_id => game["game_id"].to_i
    })

    puts "Saving red player score..."
    pp red_score

    red_score.save

    blue_score = MatchScore.create({
      :match_id => match.id,
      :player_id => blue_player_score["user_id"].to_i,
      :beatmap_id => game["beatmap_id"].to_i,
      :raw_json => blue_player_score.to_json,
      :online_game_id => game["game_id"].to_i
    })

    puts "Saving blue player score..."
    pp blue_score

    blue_score.save
  end

  # Every valid tournament map in a match must have recorded two scores otherwise the match didn't parse properly
  raise Exceptions::MatchParseFailedError unless MatchScore.where(:match_id => match.id).length == match_games.length * 2
end

def parse_match(match, raw, match_name)
  players = match["match"]["name"].split(/OIWT[\s(:\s)]/)[1].split(" vs ")

  player_red_name = players[0].tr(" ()", "")
  player_blue_name = players[1].tr(" ()", "")

  @player_red = Player.find_by_name(player_red_name)
  @player_blue = Player.find_by_name(player_blue_name)

  if @player_red == nil
    @player_red = load_api_player player_red_name
  end

  if @player_blue == nil
    @player_blue = load_api_player player_blue_name
  end

  db_match = Match.create({
    :online_id => match["match"]["match_id"],
    :match_name => match_name,
    :match_timestamp => DateTime.parse(match["match"]["start_time"]),
    :api_json => raw,
    :player_blue => @player_blue,
    :player_red => @player_red
  })

  db_match.save

  parse_match_games match["games"], db_match
end

namespace :osustats do
  desc "Add a new match to the stats tracking by the osu! multiplayer match ID"
  task :add_match, [:match_id, :match_name] => [:environment] do |task, args|
    puts "Fetch details for match id #{args[:match_id]} from osu! API"

    http = Net::HTTP.new("osu.ppy.sh", 443)
    http.use_ssl = true

    resp = http.get("/api/get_match?k=#{ENV["OSU_API_KEY"]}&mp=#{args[:match_id]}")

    ActiveRecord::Base.transaction do
      begin
        parse_match(JSON.parse(resp.body), resp.body, args[:match_name])
      rescue StandardError => e
        puts "Failed to parse match", e
        puts e.backtrace.join("\n")
        raise ActiveRecord::Rollback
      end
    end
  end
end
