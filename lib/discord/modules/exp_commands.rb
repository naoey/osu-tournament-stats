require_relative "../commands/exp/exp"

module ExpCommands
  def self.init(bot)
    bot.register_application_command(:exp, "Get exp information for a user or self") do |cmd|
      Exp.required_options.each { |o, k| cmd.option(*o, **k) }
    end

    bot.application_command(:exp) { |event| Exp.new(bot, event).respond }
  end
end
