require_relative '../discord/bot'

namespace :discord do
  desc 'Prune inactive members from all Discord servers'
  task :prune_kelas => [:environment] do |task, args|
    bot = Discord::OsuDiscordBot.instance

    bot.client.servers.each do |server|
      config = DiscordServer.find_by_discord_id(server.id)

      next if config.nil? || config.verified_role_id.nil?

      server.begin_prune(server.id, include_roles: [config.verified_role_id])
    end
  end
end
