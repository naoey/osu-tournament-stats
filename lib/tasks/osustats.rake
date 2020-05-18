require 'json'
require 'csv'

namespace :osustats do
  desc 'Load a single match'
  task :load_match, %i[match_id name tournament_id red_captain blue_captain discard_list referees] => [:environment] do |task, args|
    ApiServices::OsuApi.new.load_match(
      osu_match_id: args[:match_id],
      tournament_id: args[:tournament_id],
      round_name: args[:name],
      red_captain: args[:red_captain],
      blue_captain: args[:blue_captain],
      discard_list: args[:discard_list].nil? ? nil : args[:discard_list].split('|').map(&:to_i),
      referees: args[:referees].nil? ? nil : args[:referees].split('|').map(&:to_i),
    )
  end

  desc 'Load a CSV of matches'
  task :load_match_csv, %i[csv_path tournament_id] => [:environment] do |task, args|
    csv = CSV.parse(File.read(args[:csv_path]), headers: true)

    csv.each do |row|
      next if row['link'].downcase == 'forfeit'

      begin
        ApiServices::OsuApi.new.load_match(
          osu_match_id: row['link'].split('/').last.to_i,
          tournament_id: args[:tournament_id].to_i,
          round_name: row['name'],
          red_captain: row['red_captain'],
          blue_captain: row['blue_captain'],
          referees: row['referees'].split('|'),
          discard_list: JSON.parse(row['discard']),
        )
      rescue OsuApiParserExceptions::MatchExistsError
        puts 'Skipping existing match'
      end
    end
  end

  desc 'Load an osu! API format JSON match'
  task :load_match_json, %i[json_file_path name tournament_id red_captain blue_captain discard_list referees] => [:environment] do |_, args|
    json = JSON.parse(File.read(args[:json_file_path]))

    ApiServices::OsuApi.new.load_match_from_json(
      json,
      round_name: args[:name],
      red_captain: args[:red_captain],
      blue_captain: args[:blue_captain],
      discard_list: args[:discard_list].nil? ? nil : args[:discard_list].split('|').map(&:to_i),
      referees: args[:referees].nil? ? nil : args[:referees].split('|'),
      tournament_id: args[:tournament_id],
    )
  end

  desc 'Re-calculate scores'
  task :recalc => :environment do
    MatchScore.all.each do |score|
      # find this player's team id
      if score.match.red_team.players.include?(score.player)
        player_team = score.match.red_team
        other_team = score.match.blue_team
      else
        player_team = score.match.blue_team
        other_team = score.match.red_team
      end

      # find both teams total scores
      player_team_score = MatchScore
        .where({ player: player_team.players, match: score.match, beatmap: score.beatmap })
        .sum(:score)

      other_team_score = MatchScore
        .where({ player: other_team.players, match: score.match, beatmap: score.beatmap })
        .sum(:score)

      score.update(
        is_win: player_team_score > other_team_score,
        is_full_combo: score.count_miss.zero? && (score.beatmap.max_combo - score.max_combo) <= 0.01 * score.beatmap.max_combo
      )
    end
  end
end
