require 'pp'

namespace :osustats do
  desc "Add a new match to the stats tracking by the osu! multiplayer match ID"
  task :add_match, [:match_id] => [:environment] do |task, args|
    puts "Adding new match with ID #{args[:match_id]} and osu API #{pp ENV}"
  end
end
