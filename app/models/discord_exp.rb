class DiscordExp < ApplicationRecord
  belongs_to :player, optional: false
  belongs_to :discord_server, optional: false
end
