require 'net/http'
require 'net/https'
require 'json'
require 'date'
require 'pp'

def load_api_player(username)
  http = Net::HTTP.new("osu.ppy.sh", 443)
  http.use_ssl = true

  puts "Fetching details for user #{username} from API"

  resp = http.get("/api/get_user?k=#{ENV["OSU_API_KEY"]}&u=#{username}")

  api_player = JSON.parse(resp.body)[0]

  Player.create({
      :name => api_player["username"],
      :id => api_player["user_id"].to_i
  }).save
end

def load_api_beatmap(beatmap_id)
  http = Net::HTTP.new("osu.ppy.sh", 443)
  http.use_ssl = true

  puts "Fetching details for beatmap #{beatmap_id} from API"

  resp = http.get("/api/get_beatmaps?k=#{ENV["OSU_API_KEY"]}&b=#{beatmap_id}")

  api_beatmap = JSON.parse(resp.body)[0]

  Beatmap.create({
    :name => "#{api_beatmap["artist"]} - #{api_beatmap["title"]}",
    :online_id => api_beatmap["beatmap_id"].to_i,
    :difficulty_name => api_beatmap["version"],
    :star_difficulty => api_beatmap["difficultyrating"].to_f
  }).save
end

def parse_match_games(games, match)
  match_games = games.select do |game|
    game["team_type"] == "2" && game["scoring_type"] == "3" && game["scores"].length == 3
  end

  puts "Parsing #{match_games.length} match games"

  match_games.each do |game|
    red_player_score = game["scores"].find { |score| score["slot"] == "0" }
    blue_player_score = game["scores"].find { |score| score["slot"] == "1" }

    if Beatmap.find_by_online_id(game["beatmap_id"].to_i) == nil
      load_api_beatmap game["beatmap_id"]
    end

    MatchScore.create({
      :match_id => match,
      :player_id => Player.find(red_player_score["user_id"].to_i),
      :beatmap_id => Beatmap.find_by_online_id(game["beatmap_id"]),
      :raw_json => red_player_score.to_json
    }).save

    MatchScore.create({
      :match_id => match,
      :player_id => Player.find(blue_player_score["user_id"].to_i),
      :beatmap_id => Beatmap.find_by_online_id(game["beatmap_id"]),
      :raw_json => blue_player_score.to_json
    }).save
  end
end

def parse_match(match, raw)
  # TODO: remove this when committing for real use
  players = "OIWT: (nitr0f) vs (SpaceMaster77)".split(":")[1].split(" vs ")
  # players = match["match"]["name"].split(":")[1].split(" vs ")

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
    :match_timestamp => DateTime.parse(match["match"]["start_time"]),
    :api_json => raw,
    :player_blue => @player_blue,
    :player_red => @player_red
  }).save

  parse_match_games match["games"], db_match
end

namespace :osustats do
  desc "Add a new match to the stats tracking by the osu! multiplayer match ID"
  task :add_match, [:match_id] => [:environment] do |task, args|
    puts "Fetch details for match id #{args[:match_id]} from osu! API"

    http = Net::HTTP.new("osu.ppy.sh", 443)
    http.use_ssl = true

    resp = http.get("/api/get_match?k=#{ENV["OSU_API_KEY"]}&mp=#{args[:match_id]}")

    parse_match(JSON.parse(resp.body), resp.body)
  end
end
