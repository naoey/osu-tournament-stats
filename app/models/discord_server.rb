class DiscordServer < ApplicationRecord
  has_many :osu_auth_requests, foreign_key: 'discord_server_id'
  has_many :discord_exps
end
