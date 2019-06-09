namespace :osustats do
  desc "Add a new match to the stats tracking by the osu! multiplayer match ID"
  task :add_match, [:match_id, :round_name] => [:environment] do |task, args|
    MatchServices::OsuApiParser.new.load_match(osu_match_id: args[:match_id], round_name: args[:round_name])
  end
end
