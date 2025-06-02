require_relative '../../lib/discord/bot'

class MonthlyKelaJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ::Discord::OsuDiscordBot.instance.initialize! do |bot|
      bot.kela!
    end
  end
end
