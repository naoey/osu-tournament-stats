require 'net/http'
require 'net/https'
require 'json'
require 'date'
require 'yaml'

module ApiServices
  ##
  # Service class to load game data with fallback to the osu! API.
  class OsuApi
    ##
    # Loads a new match and adds it to the database. It differs from +load_match+ in that it accepts an optional third argument
    # which is an array of indices which indicate which game indexes to discard while parsing the match.
    def load_match(osu_match_id:, round_name: nil, tournament_id: nil, discard_list: nil)
      Rails.logger.tagged(self.class.name) { Rails.logger.info "Fetch details for match id #{osu_match_id} from osu! API" }

      unless Match.find_by_online_id(osu_match_id).nil?
        Rails.logger.tagged(self.class.name) { Rails.logger.info "Match #{osu_match_id} already exists in database, skipping API load" }
        raise OsuApiParserExceptions::MatchExistsError, "Match #{osu_match_id} already exists in database"
      end

      http = Net::HTTP.new('osu.ppy.sh', 443)
      http.use_ssl = true

      resp = http.get("/api/get_match?k=#{ENV['OSU_API_KEY']}&mp=#{osu_match_id}")

      begin
        json = JSON.parse(resp.body)
      rescue JSON::ParserError => e
        raise OsuApiParserExceptions::MatchParseFailedError, 'Failed to load match from osu! API'
      end

      # TODO: eventually this will have to identify team names and not player names
      players = correct_match_name(json['match']['name'], osu_match_id).split(/:/)

      Rails.logger.tagged { Rails.logger.debug "Determining players from match name part 1 #{players}" }

      raise OsuApiParserExceptions::MatchParseFailedError, "Match name doesn't match tournament format!" unless players.length >= 2

      players = players[1].split(/\s?vs?.?\s?/i)

      Rails.logger.tagged { Rails.logger.debug "Determining players from match name part 2 #{players}" }

      raise OsuApiParserExceptions::MatchParseFailedError, "Match name doesn't match tournament format!" unless players.length == 2

      ActiveRecord::Base.transaction do
        red_team = MatchTeam.create(
          name: players[0].tr(' ()', '')
        )

        red_team.save!

        blue_team = MatchTeam.create(
          name: players[1].tr(' ()', '')
        )

        blue_team.save!

        db_match = Match.create(
          online_id: json['match']['match_id'],
          round_name: round_name,
          match_timestamp: DateTime.parse(json['match']['start_time']),
          red_team: red_team,
          blue_team: blue_team,
          tournament_id: tournament_id
        )

        db_match.save

        # we need to discard games at the given indexes for whatever reason
        Rails.logger.tagged(self.class.name) { Rails.logger.info "Discarding games #{discard_list}" }

        games_after_discard = []

        # remove maps that are to be discardede
        json['games'].each.with_index { |g, i| games_after_discard.push(g) unless discard_list.include? i }

        # remove aborted maps
        games_after_discard = games_after_discard.filter { |g| !g['scores'].empty? }

        parse_match_games games_after_discard, db_match, red_team: red_team, blue_team: blue_team

        Rails.logger.tagged(self.class.name) { Rails.logger.debug('Finished parsing games, determining winner') }

        db_match.winner = match_winner?(json['games'], red_team, blue_team)
        db_match.save
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
      Rails.logger.tagged(self.class.name) { Rails.logger.debug("Fetching player information for player #{username}") }

      player = Player
        .where('LOWER(name) = ?', username.to_s.downcase)
        .or(Player.where(id: username))

      return player[0] unless player.empty?

      http = Net::HTTP.new('osu.ppy.sh', 443)
      http.use_ssl = true

      resp = http.get("/api/get_user?k=#{ENV['OSU_API_KEY']}&u=#{username}")

      json = JSON.parse(resp.body)

      raise OsuApiParserExceptions::PlayerLoadFailedError, "Player #{username} not found on osu! server" if json.empty?

      api_player = json[0]

      player = Player.find_by_id(api_player['user_id'].to_i)

      if !player.nil? && player.name != api_player['username']
        Rails.logger.tagged(self.class.name) { Rails.logger.warn("Player with ID #{api_player['username']} already exists but name doesn't match, updating #{player.name} => #{api_player['username']}") }
        player.name = api_player['username']
      elsif player.nil?
        player = Player.create(
          name: api_player['username'],
          id: api_player['user_id'].to_i
        )
      end

      player.save!

      player
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

      return beatmap unless beatmap.nil?

      raise 'Missing osu! API key' if ENV['OSU_API_KEY'].nil?

      http = Net::HTTP.new('osu.ppy.sh', 443)
      http.use_ssl = true

      Rails.logger.tagged(self.class.name) { Rails.logger.debug "Fetching details for beatmap #{beatmap_id} from API" }

      resp = http.get("/api/get_beatmaps?k=#{ENV['OSU_API_KEY']}&b=#{beatmap_id}")

      json = JSON.parse(resp.body)

      if json.length.zero?
        Rails.logger.warn "Beatmap with ID #{beatmap_id} doesn't exist on osu server, using dummy beatmap"
        dummy = Beatmap.find_by_online_id(-1)

        if dummy.nil?
          dummy = Beatmap.create(online_id: -1, name: 'Dummy beatmap')
          dummy.save!
        end

        return dummy
      end

      api_beatmap = json[0]

      beatmap = Beatmap.create(
        name: "#{api_beatmap['artist']} - #{api_beatmap['title']}",
        online_id: api_beatmap['beatmap_id'].to_i,
        difficulty_name: api_beatmap['version'],
        star_difficulty: api_beatmap['difficultyrating'].to_f,
        max_combo: api_beatmap['max_combo'].to_i
      )

      beatmap.save!

      beatmap
    end

    private

    def parse_match_games(games, match, red_team: nil, blue_team: nil)
      puts "Parsing #{games.length} match games"

      # marker to know whether the games were parsed correctly
      total_score_count = 0

      games.each do |game|
        red_team_scores = game['scores'].select { |score| score['team'] == '0' }
        blue_team_scores = game['scores'].find { |score| score['team'] == '1' }

        total_score_count += red_team_scores.length
        total_score_count += blue_team_scores.length

        get_or_load_beatmap game['beatmap_id'].to_i

        MatchScore.create(red_team_scores.map { |_s| create_match_score(match, game, score) })
        new_red_team_members = red_team.players.map(&:osu_id) - (red_team_scores.map { |p| p.user_id.to_i })
        red_team.players.push(new_red_team_members.map(&method(:get_or_load_player)))

        red_team.save!

        Rails.logger.tagged(self.class.name) { Rails.logger.debug 'Red player scores saved' }

        MatchScore.create(blue_team_scores.map { |_s| create_match_score(match, game, score) })
        new_blue_team_members = red_team.players.map(&:osu_id) - (blue_team_scores.map { |p| p.user_id.to_i })
        blue_team.players.push(new_blue_team_members.map(&method(:get_or_load_player)))

        blue_team.save!

        Rails.logger.tagged(self.class.name) { Rails.logger.debug 'Blue player scores saved' }
      end

      matches_in_db = MatchScore.where(match: match).count(:all)

      return unless matches_in_db != total_score_count

      raise OsuApiParserExceptions::MatchParseFailedError, "Match parse failed. Found #{matches_in_db} scores parsed, expected #{games.length * 2 - nil_score_count}"
    end

    def create_match_score(match, game, player_score)
      {
        match: match,
        beatmap_id: game['beatmap_id'].to_i,
        online_game_id: game['game_id'].to_i,
        player_id: player_score['user_id'].to_i,
        score: player_score['score'].to_i,
        max_combo: player_score['maxcombo'].to_i,
        count_50: player_score['count50'].to_i,
        count_100: player_score['count100'].to_i,
        count_300: player_score['count300'].to_i,
        count_geki: player_score['countgeki'].to_i,
        count_katu: player_score['count_katu'].to_i,
        count_miss: player_score['countmiss'].to_i,
        perfect: player_score['perfect'] == '1',
        pass: player_score['pass'] == '1',
      }
    end

    def match_winner?(match_games, red_team, blue_team)
      winners = YAML.load_file(File.join(Rails.root, 'config', 'preset_match_winners.yml'))

      if winners.key?(match_id)
        return red_team if winners[match_id] == 'red'

        return blue_team if winners[match_id] == 'blue'

        raise OsuApiParserExceptions::MatchParseFailedError, "Match #{match_id} has entry in winner overrides but is an unrecognised value"
      end

      Rails.logger.tagged(self.class.name) { Rails.logger.info("Determining winner from #{match_games.length} match games") }

      blue_wins = 0
      red_wins = 0

      match_games.each do |g|
        team_totals = g['scores']
          .select { |s| s['pass'] == '1' }
          .map { |s| s['score'] = s['score'].to_i }
          .group_by { |s| s['team'] }

        if team_totals['0'].empty? && team_totals['1'].empty?
          raise OsuApiParserExceptions::MatchParseFailedError, 'Impossible situation where map has no passes at all'
        end

        red_total = team_totals['0'].reduce(:+)
        blue_total = team_totals['1'].reduce(:+)

        if red_total == blue_total
          raise OsuApiParserExceptions::MatchParseFailedError, 'Impossible situation where red and blue teams have identical score'
        end

        map_winner = if red_total > blue_total
                       red_wins += 1
                     else
                       blue_wins += 1
                     end
      end

      Rails.logger.tagged { Rails.logger.debug("Determined wins: blue: #{blue_wins}, red: #{red_wins}") }

      if red_wins == blue_wins
        raise OsuApiParserExceptions::MatchParseFailedError, 'Impossible situation where red and blue have equal wins in a match'
      end

      return red_team if red_wins > blue_wins

      blue_team
    end

    def correct_match_name(name, match_id)
      # TODO: these correction YAML files should be removed once match correction is implemented in UI
      corrections = YAML.load_file(File.join(Rails.root, 'config', 'match_winner_corrections.yml'))

      if corrections.key?(match_id)
        Rails.logger.tagged(self.class.name) { Rails.logger.warn("Correcting match name #{name} => #{corrections[match_id]}") }
        corrections[match_id]
      else
        name
      end
    end
  end
end
