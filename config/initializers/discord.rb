require_relative '../../lib/discord/bot'

Discord::OsuDiscordBot.instance.initialize! if ENV['DISCORD_ENABLED'] == '1'

at_exit do
  Discord::OsuDiscordBot.instance.close!
end
