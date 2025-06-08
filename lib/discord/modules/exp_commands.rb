require_relative "../commands/exp/exp"
require_relative "../commands/exp/exp_leaderboard"

module ExpCommands
  def self.init(bot)
    bot.application_command(:exp) { |event| Exp.new(bot, event).respond }
    bot.application_command(:exp_leaderboard) { |event| ExpLeaderboard.new(bot, event).respond }
  end

  def self.register(bot)
    bot.register_application_command(:exp, "Get exp information for a user or self") do |cmd|
      Exp.required_options.each { |o, k| cmd.option(*o, **k) }
    end

    bot.register_application_command(:exp_leaderboard, "Show the current leaderboard for KelaBot XP")
  end
end
