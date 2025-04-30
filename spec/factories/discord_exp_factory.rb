FactoryBot.define do
  factory :discord_exp do
    discord_server { create(:discord_server) }
    exp { 0 }
    detailed_exp { DiscordHelper::INITIAL_EXP.clone }
    level { 0 }
    message_count { 0 }
  end
end
