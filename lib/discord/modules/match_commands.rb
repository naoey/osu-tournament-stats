require "discordrb"

require_relative "../commands/match_stats"

module MatchCommands
  extend Discordrb::Commands::CommandContainer

  command(:match, aliases: [:m], description: "View match stats") { |event, *args| MatchStats.new(event, *args).response }
end
