require_relative '../../lib/discord/bot'

Discord::OsuDiscordBot.new if ENV['DISCORD_ENABLED'] == '1'
