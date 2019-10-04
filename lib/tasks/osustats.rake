require 'json'
require 'csv'

namespace :osustats do
  desc 'Load a CSV of matches'
  task :load_match_csv, %i[csv_path round_name tournament_id] => [:environment] do |task, args|
    csv = CSV.parse(File.read(args[:csv_path]), headers: true)

    csv.each do |row|
      next if row['MP Links'].downcase == 'forfeit'

      discard = JSON.parse(row['Discard List']).map { |i| i - 1 }
      match_id = row['MP Links'].split('/').last.to_i

      begin
        ApiServices::OsuApi.new.load_match(
          osu_match_id: match_id,
          tournament_id: args[:tournament_id].to_i,
          round_name: args[:round_name],
          discard_list: discard,
        )
      rescue OsuApiParserExceptions::MatchExistsError
        puts 'Skipping existing match'
      end
    end
  end
end
