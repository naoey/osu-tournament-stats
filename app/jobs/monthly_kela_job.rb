require_relative '../../lib/discord/bot'

class MonthlyKelaJob < ApplicationJob
  include SemanticLogger

  queue_as :default

  def perform(reason)
    logger.info("Starting monthly kela job")

    ::Discord::OsuDiscordBot.instance.initialize! do |bot|
      bot.kela!(reason)
    end
  end
end
