require "discordrb"

require_relative "../commands/score_leaderboard"
require_relative "../commands/exp/exp_leaderboard"

module LeaderboardCommands
  extend Discordrb::Commands::CommandContainer

  command(:leaderboard, aliases: [:lb], description: "View player leaderboard") do |event, *args|
    ScoreLeaderboard.new(event, *args).response
  end

  command(:exp_leaderboard, aliases: [:xp_lb], description: "View Discord exp leaderboard") do |event, *args|
    ExpLeaderboard.new(event, *args).response
  end
end
