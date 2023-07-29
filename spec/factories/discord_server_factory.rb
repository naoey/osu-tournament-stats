FactoryBot.define do
  factory :discord_server do
    discord_id { DiscordServer.count + 1 }
  end
end
