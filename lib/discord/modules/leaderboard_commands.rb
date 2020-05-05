require 'discordrb'

require_relative '../commands/score_leaderboard'

module LeaderboardCommands
  extend Discordrb::Commands::CommandContainer

  command(:score_leaderboard, aliases: [:slb], description: 'View player leaderboard') do |event, *args|
    ScoreLeaderboard.new(event, *args).response
  end
end
