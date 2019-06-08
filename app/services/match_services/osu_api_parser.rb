require 'net/http'
require 'net/https'
require 'json'
require 'date'

module MatchServices

  ##
  # Service class to load game data with fallback to the osu! API.
  class OsuApiParser
    ##
    # Loads a new match and adds it to the database, associating it with a given tournament + round or a single match. If any dependent
    # data such as players/beatmaps are missing, they are loaded from the API as well.
    #
    # Parameters:
    # +osu_match_id+:: The ID of the multiplayer match on osu! servers
    # +associated_match_id+:: The ID of the associated match in tournament manager's database to which this match's details are to be added
    # +round_name+:: If this match is part of a tournamnent, optionally specify a round name to display in the tournament details
    #
    # @return [Match]
    def load_match(osu_match_id:, round_name: nil)
      Rails.logger.tagged("OsuApiParser") { Rails.logger.info "Fetch details for match id #{osu_match_id} from osu! API" }

      raise OsuApiParserExceptions::MatchExistsError.new("Match #{osu_match_id} already exists in database") unless Match.find_by_online_id(osu_match_id) == nil

      http = Net::HTTP.new("osu.ppy.sh", 443)
      http.use_ssl = true

      resp = http.get("/api/get_match?k=#{ENV["OSU_API_KEY"]}&mp=#{osu_match_id}")

      raise OsuApiParserExceptions::MatchParseFailedError.new("Failed to load match #{match_id} from osu! API") if !resp.body

      ActiveRecord::Base.transaction do
        begin
          # TODO: eventually this will have to identify team names and not player names
          players = match["match"]["name"].split(/OIWT[\s:]{0,3}/)[1].split(/\svs.?\s/)

          @player_blue = get_or_load_player players[0].tr(" ()", "")
          @player_red = get_or_load_player players[1].tr(" ()", "")

          db_match = Match.create({
            :online_id => match["match"]["match_id"],
            :round_name => round_name,
            :match_timestamp => DateTime.parse(match["match"]["start_time"]),
            :api_json => raw,
            :player_blue => @player_blue,
            :player_red => @player_red
          })

          db_match.save

          # TODO: handle all game mode combinations
          match["games"] = match["games"].select do |game|
            game["team_type"] == "2" && game["scoring_type"] == "3" && game["scores"].length == 3
          end

          # we need to filter out maps that were replayed for whatever reason
          # when a map has been played multiple times, always pick the game that was started last for that map ID
          match["games"] = match["games"].group_by{|g| g["beatmap_id"]}.map {|_,v| v.max_by {|g| DateTime.parse(g["start_time"])}}

          parse_match_games match["games"], db_match

          db_match.winner = match_winner?(match["games"], db_match.player_red.id, db_match.player_blue.id)
          db_match.save

          return db_match
        rescue StandardError => e
          puts "Failed to parse match", e
          puts e.backtrace.join("\n")
          raise ActiveRecord::Rollback
        end
      end
    end

    ##
    # Retrieves a +Player+ from the database if it exists, otherwise loads the player from the osu! API.
    #
    # Parameters:
    # +user_name_or_id+:: The user's name or osu! user ID
    #
    # @return [Player]
    def get_or_load_player(username)
      Rails.logger.tagged("OsuApiParser") { Rails.logger.debug("Fetching player information for player #{username}") }

      player = Player
        .where('LOWER(name) = ?', username.downcase)
        .or(Player.where(:id => username))

      if player.length != 0
        return player[0]
      end

      http = Net::HTTP.new("osu.ppy.sh", 443)
      http.use_ssl = true

      resp = http.get("/api/get_user?k=#{ENV["OSU_API_KEY"]}&u=#{username}")

      json = JSON.parse(resp.body)

      if json.length == 0
        raise OsuApiParserExceptions::PlayerLoadFailedError.new("Player #{username} not found on osu! server")
      end

      api_player = json[0]

      player = Player.create({
        :name => api_player["username"],
        :id => api_player["user_id"].to_i
      })

      player.save!

      return player
    end

    ##
    # Retrieves a +Beatmap+ from the database if it exists, otherwise loads teh beatmap from the osu! API.
    #
    # Parameters:
    # +beatmap_id+:: The ID of the beatmap to load
    #
    # @return [Beatmap]
    def get_or_load_beatmap(beatmap_id)
      beatmap = Beatmap.find_by_online_id(beatmap_id)

      if beatmap != nil
        return beatmap
      end

      http = Net::HTTP.new("osu.ppy.sh", 443)
      http.use_ssl = true

      Rails.logger.tagged("OsuApiParser") { Rails.logger.debug "Fetching details for beatmap #{beatmap_id} from API" }

      resp = http.get("/api/get_beatmaps?k=#{ENV["OSU_API_KEY"]}&b=#{beatmap_id}")

      json = JSON.parse(resp.body)

      if json.length == 0
        raise OsuApiParserExceptions::BeatmapLoadFailedError.new("Beatmap with id #{beatmap_id} not found on osu! server")
      end

      beatmap = Beatmap.create({
        :name => "#{api_beatmap["artist"]} - #{api_beatmap["title"]}",
        :online_id => api_beatmap["beatmap_id"].to_i,
        :difficulty_name => api_beatmap["version"],
        :star_difficulty => api_beatmap["difficultyrating"].to_f,
        :max_combo => api_beatmap["max_combo"].to_i
      })

      beatmap.save!

      return beatmap
    end

    private
    def parse_match_games(games, match)
      puts "Parsing #{games.length} match games"

      games.each do |game|
        Rails.logger.tagged("OsuApiParser") { Rails.logger.debug "Parsing game..." }

        blue_player_score = game["scores"].find { |score| score["slot"] == "0" }
        red_player_score = game["scores"].find { |score| score["slot"] == "1" }

        get_or_load_beatmap game["beatmap_id"].to_i

        red_score = MatchScore.create(create_match_score(match_id, game, red_player_score))

        Rails.logger.tagged("OsuApiParser") { Rails.logger.debug "Red player score save: #{red_score.save!}" }

        blue_score = MatchScore.create(create_match_score(match_id, game, blue_player_score))

        Rails.logger.tagged("OsuApiParser") { Rails.logger.debug "Blue player score save: #{blue_score.save!}" }
      end

      # Every valid tournament map in a match must have recorded two players' scores otherwise the match didn't parse properly
      matches_in_db = MatchScore.where(:match_id => match.id).length
      if matches_in_db != games.length * 2
        raise OsuApiParserExceptions::MatchParseFailedError.new("Match parse failed. Found #{matches_in_db} scores parsed, expected #{games.length * 2}")
      end
    end

    def create_match_score(match_id, game, player_score)
      {
        :match_id => match_id,
        :beatmap_id => game["beatmap_id"].to_i,
        :online_game_id => game["game_id"].to_i,
        :player_id => player_score["user_id"].to_i,
        :score => player_score["score"].to_i,
        :max_combo => player_score["maxcombo"].to_i,
        :count_50 => player_score["count50"].to_i,
        :count_100 => player_score["count100"].to_i,
        :count_300 => player_score["count300"].to_i,
        :count_geki => player_score["countgeki"].to_i,
        :count_katu => player_score["count_katu"].to_i,
        :count_miss => player_score["countmiss"].to_i,
        :perfect => player_score["perfect"] == "1",
        :pass => player_score["pass"] == "1",
      }
    end

    def match_winner?(match_games, player_blue_id, player_red_id)
      blue_wins = 0
      red_wins = 0

      match_games.each do |g|
        map_winner = g["scores"].select {|s| s["pass"] == "1"}.max_by {|s| s["score"].to_i}["user_id"].to_i

        if map_winner == player_blue_id
          blue_wins += 1
        elsif map_winner == player_red_id
          red_wins += 1
        else
          raise OsuApiParserExceptions::MatchParseFailedError.new("Impossible situation where winner of map is not red or blue player")
        end
      end

      if blue_wins > red_wins
        return player_blue_id
      elsif red_wins > blue_wins
        return player_red_id
      end

      raise OsuApiParserExceptions::MatchParseFailedError.new("Impossible situation where red and blue have equal wins in a match")
    end
  end
end
