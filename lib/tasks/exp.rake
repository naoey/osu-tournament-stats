require 'json'
require 'rake-progressbar'

require_relative '../../app/helpers/discord_helper'

namespace :exp do
  desc 'Load MEE6 JSON into database'
  task :load, %i[json_path] => [:environment] do |task, args|
    logger = SemanticLogger["exp.rake"]

    json = JSON.parse(File.read(args[:json_path]))

    logger.info("Found #{json.count} entries in JSON file")

    bar = RakeProgressbar.new(json.count)

    ActiveRecord::Base.transaction do
      json.each do |player|
        db_player = Player.find_by_discord_id(player['id'])

        if db_player.nil?
          db_player = Player.create(
            discord_id: player['id'],
            name: DiscordHelper.sanitise_username(player['username'])
          )
        end

        db_server = DiscordServer.find_or_create_by(discord_id: player['guild_id'])
        db_player_exp = DiscordExp.find_or_create_by(
          player: db_player,
          discord_server: db_server,
          detailed_exp: DiscordHelper::INITIAL_EXP
        )

        db_player_exp.update(
          exp: player['xp'],
          level: player['level'],
          message_count: player['message_count'],
          detailed_exp: player['detailed_xp']
        )

        db_player_exp.save!

        bar.inc
      end
    end

    assert DiscordExp.count == json.count, 'All JSON records entered'

    logger.info("Inserted #{DiscordExp.count} records")

    bar.finished
  end
end
