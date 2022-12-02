if ENV['DISCORD_ENABLED'] == '1'
  require_relative '../../lib/discord/bot'

  Discord::OsuDiscordBot.instance.initialize!

  at_exit do
    Discord::OsuDiscordBot.instance.close!
  end
end

