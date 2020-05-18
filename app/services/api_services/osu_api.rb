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
    def load_match(
      osu_match_id:,
      round_name: nil,
      tournament_id: nil,
      discard_list: nil,
      red_captain: nil,
      blue_captain: nil,
      referees: nil
    )
      referees = (referees || [])
        .reject { |r| r.nil? || r.empty? }
        .map { |r| get_or_load_player(r) }
        .map(&:osu_id)

      Rails.logger.tagged(self.class.name) { Rails.logger.info "Fetch details for match id #{osu_match_id} from osu! API" }

      unless Match.find_by_online_id(osu_match_id).nil?
        Rails.logger.tagged(self.class.name) do
          Rails.logger.info "Match #{osu_match_id} already exists in database, skipping API load"
        end
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

      raise OsuApiParserExceptions::MatchParseFailedError, "Match #{osu_match_id} has no games in it" if json['games'].empty?

      load_match_from_json(
        json,
        round_name: round_name,
        tournament_id: tournament_id,
        discard_list: discard_list,
        red_captain: red_captain,
        blue_captain: blue_captain,
        referees: referees
      )
    end

    ##
    # Parses and loads a match into the database from the osu! API JSON.
    def load_match_from_json(
      json,
      round_name: nil,
      tournament_id: nil,
      discard_list: nil,
      red_captain: nil,
      blue_captain: nil,
      referees: nil
    )
      osu_match_id = json['match_id'].to_i

      team_names = correct_match_name(json['match']['name'], osu_match_id).split(/:/)

      Rails.logger.tagged { Rails.logger.debug "Determining team names from match name part 1 #{team_names}" }

      blue_team_name, red_team_name = team_names[1]&.split(/\s?vs?.?\s?/i)

      Rails.logger.tagged { Rails.logger.debug "Determining team names from match name part 2 #{team_names}" }

      ActiveRecord::Base.transaction do
        begin
          red_team = MatchTeam.create(
            name: red_team_name || 'Red team',
            captain: get_or_load_player(red_captain || get_captain(json, 2)),
          )

          red_team.save!

          blue_team = MatchTeam.create(
            name: blue_team_name || 'Blue team',
            captain: get_or_load_player(blue_captain || get_captain(json, 1)),
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

          db_match.save!

          # we need to discard games at the given indexes for whatever reason
          Rails.logger.tagged(self.class.name) { Rails.logger.info "Discarding games #{discard_list}" }

          games_after_discard = []

          # first remove maps that were aborted since they are not shown on the website. discard list needs to be evaluated only
          # after that since index counting will be done from what appears on osu website
          json['games'] = json['games'].reject { |g| g['end_time'].nil? || g['scores'].nil? }

          # then from the remaining games, discard maps being given in discard list
          if discard_list
            json['games'].each.with_index { |g, i| games_after_discard.push(g) unless discard_list.include? i }
          else
            games_after_discard = json['games']
          end

          parse_match_games(games_after_discard, db_match, red_team: red_team, blue_team: blue_team, referees: referees)

          Rails.logger.tagged(self.class.name) { Rails.logger.debug('Finished parsing games, determining winner') }

          db_match.winner = match_winner?(games_after_discard, red_team, blue_team, osu_match_id, referees: referees)
          db_match.save!

          db_match
        rescue StandardError => e
          Rails.logger.tagged(self.class.name) do
            Rails.logger.error('Error while parsing match. Internal error:')
            Rails.logger.error(e.backtrace.join('\n'))
          end

          raise ActiveRecord::Rollback
        end
      end
    end

    ##
    # Retrieves a +Player+ from the database if it exists, otherwise loads the player from the osu! API.
    #
    # Parameters:
    # +user_name_or_id+:: The user's name or osu! user ID
    # +force_update+:: Whether to skip retrieval and forcibly update from osu! API (useful for username updates)
    #
    # @return [Player]
    def get_or_load_player(username, force_update: false)
      Rails.logger.tagged(self.class.name) { Rails.logger.debug("Fetching player information for player #{username}") }

      player = Player
        .where('LOWER(name) = ?', username.to_s.downcase)
        .or(Player.where(osu_id: username))

      return player[0] unless player.empty? || force_update

      http = Net::HTTP.new('osu.ppy.sh', 443)
      http.use_ssl = true

      resp = http.get("/api/get_user?k=#{ENV['OSU_API_KEY']}&u=#{username}")

      json = JSON.parse(resp.body)

      raise OsuApiParserExceptions::PlayerLoadFailedError, "Player #{username} not found on osu! server" if json.empty?

      api_player = json[0]

      player = Player.find_by_osu_id(api_player['user_id'].to_i)

      if !player.nil? && player.name != api_player['username']
        Rails.logger.tagged(self.class.name) do
          Rails.logger.warn(
            "Player with ID #{api_player['username']} already exists but name doesn't match, "\
            "updating #{player.name} => #{api_player['username']}",
          )
        end
        player.name = api_player['username']
      elsif player.nil?
        player = Player.create(
          name: api_player['username'],
          osu_id: api_player['user_id'].to_i,
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

    def get_captain(json, team_id)
      json['games']
        .select { |g| g['team_type'] == '2' && !g['scores'].empty? }
        .first['scores']
        .select { |s| s['team'] == team_id.to_s }
        .first['user_id']
        .to_i
    end

    def parse_match_games(games, match, red_team: nil, blue_team: nil, referees: nil)
      puts "Parsing #{games.length} match games"

      # marker to know whether the games were parsed correctly
      total_score_count = 0

      games.each do |game|
        red_team_scores = game['scores'].select { |score|
          score['team'] == '2' && !referees.include?(score['user_id'].to_i) && score['pass'] == '1'
        }
        blue_team_scores = game['scores'].select { |score|
          score['team'] == '1' && !referees.include?(score['user_id'].to_i) && score['pass'] == '1'
        }

        total_score_count += red_team_scores.length
        total_score_count += blue_team_scores.length

        beatmap = get_or_load_beatmap game['beatmap_id'].to_i

        red_team_total_score = red_team_scores.map { |s| s['score'].to_i }.reduce(0, :+)
        blue_team_total_score = blue_team_scores.map { |s| s['score'].to_i }.reduce(0, :+)

        red_team_scores.each do |score|
          s = MatchScore.new(create_match_score(
            match,
            game,
            score,
            red_team_total_score > blue_team_total_score,
            score['count_miss'].to_i.zero? && (beatmap.max_combo - score['max_combo'].to_i) <= 0.01 * beatmap.max_combo,
          ))

          s.accuracy = StatCalculationHelper.calculate_accuracy(s)

          s.save!

          match.match_scores.push(s)
        end

        new_red_team_members = (red_team_scores.map { |p| p['user_id'].to_i }) - red_team.players.map(&:osu_id)
          .reject { |p| referees.include?(p) }
        red_team.players.push(new_red_team_members.map(&method(:get_or_load_player)))

        red_team.save!

        Rails.logger.tagged(self.class.name) { Rails.logger.debug 'Red player scores saved' }

        blue_team_scores.each do |score|
          s = MatchScore.new(create_match_score(
            match,
            game,
            score,
            blue_team_total_score > red_team_total_score,
            score['count_miss'].to_i.zero? && (beatmap.max_combo - score['max_combo'].to_i) <= 0.01 * beatmap.max_combo,
          ))

          s.accuracy = StatCalculationHelper.calculate_accuracy(s)

          s.save!

          match.match_scores.push(s)
        end

        new_blue_team_members = (blue_team_scores.map { |p| p['user_id'].to_i }) - blue_team.players.map(&:osu_id)
          .reject { |p| referees.include?(p) }
        blue_team.players.push(new_blue_team_members.map(&method(:get_or_load_player)))

        blue_team.save!

        Rails.logger.tagged(self.class.name) { Rails.logger.debug 'Blue player scores saved' }
      end

      scores_in_db = MatchScore.where(match_id: match.id).count(:all)

      return unless scores_in_db != total_score_count

      raise OsuApiParserExceptions::MatchParseFailedError,
            "Match parse failed. Found #{scores_in_db} scores parsed, expected #{total_score_count}"
    end

    def create_match_score(match, game, player_score, is_win, is_fc)
      {
        match: match,
        beatmap: get_or_load_beatmap(game['beatmap_id'].to_i),
        online_game_id: game['game_id'].to_i,
        player: get_or_load_player(player_score['user_id'].to_i),
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
        is_full_combo: is_fc,
        is_win: is_win,
      }
    end

    def match_winner?(match_games, red_team, blue_team, match_id, referees: nil)
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
        next if g['scores'].empty?

        team_totals = g['scores']
          .select { |s| s['pass'] == '1' && !referees.include?(s['user_id'].to_i) }
          .each do |s|
          s['score'] = s['score'].to_i

          if s['team'] == '1'
            s['team'] = 'blue'
          elsif s['team'] == '2'
            s['team'] = 'red'
          end
        end

        team_totals = team_totals.group_by { |s| s['team'] }

        team_totals['red'] = [] if team_totals['red'].nil?
        team_totals['blue'] = [] if team_totals['blue'].nil?

        if team_totals['red'].empty? && team_totals['blue'].empty?
          raise OsuApiParserExceptions::MatchParseFailedError,
                "Impossible situation where map with beatmap id #{g['beatmap_id']} has no passes at all"
        end

        red_total = team_totals['red'].map { |s| s['score'] }.reduce(:+) || 0
        blue_total = team_totals['blue'].map { |s| s['score'] }.reduce(:+) || 0

        Rails.logger.tagged(self.class.name) { Rails.logger.info("Wins are red: #{red_wins}, blue: #{blue_wins}") }

        if red_total == blue_total
          raise OsuApiParserExceptions::MatchParseFailedError, 'Impossible situation where red and blue teams have identical score'
        end

        if red_total > blue_total
          red_wins += 1
        else
          blue_wins += 1
        end
      end

      if red_wins == blue_wins
        raise OsuApiParserExceptions::MatchParseFailedError, 'Impossible situation where red and blue have equal wins in a match'
      end

      Rails.logger.tagged(self.class.name) { Rails.logger.info('Winner determined') }

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
