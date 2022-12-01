import 'json'

namespace :exp do
  desc 'Load MEE6 JSON into database'
  task :load, %i[json_path] => [:environment] do |task, args|
    json = JSON.parse(File.read(args[:json_path]))

    json.each do |player|
      db_player = Player.find_or_create_by(discord_id: player.id)
      db_player_exp = PlayerDiscordExp.find_or_create_by(player: db_player)

      db_player_exp.update(
        player: p,
        exp: player.xp,
        level: player.level,
        message_count: player.message_count,
        detailed_exp: player.detailed_xp
      )

      db_player_exp.save!
    end
  end
end
