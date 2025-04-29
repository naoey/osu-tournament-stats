FactoryBot.define do
  factory :discord_server do
    discord_id { Random.rand }
    exp_enabled { true }
    exp_roles_config { [] }
    verification_log_channel_id { 1 }
    guest_role_id { 1 }
  end
end
