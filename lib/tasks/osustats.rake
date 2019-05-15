namespace :osustats do
  desc "Add a new match to the stats tracking by the osu! multiplayer match ID"
  task :add_match, [:match_id, :round_name] => [:environment] do |task, args|
    MatchServices::OsuApiParser.new.add_match(args[:match_id], args[:round_name])
  end
end
