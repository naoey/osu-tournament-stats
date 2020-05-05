require 'discordrb'

require_relative '../commands/score_leaderboard'

module LeaderboardCommands
  extend Discordrb::Commands::CommandContainer

  command(:leaderboard, aliases: [:lb], description: 'View player leaderboard') do |event, *args|
    ScoreLeaderboard.new(event, *args).response
  end
end
