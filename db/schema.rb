# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_02_082834) do
  create_table "auth_providers", primary_key: "name", id: :string, charset: "utf8mb3", force: :cascade do |t|
    t.string "display_name"
    t.boolean "enabled"
  end

  create_table "ban_histories", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "banned_by_id"
    t.integer "ban_type", default: 0, null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["banned_by_id"], name: "index_ban_histories_on_banned_by_id"
    t.index ["player_id"], name: "index_ban_histories_on_player_id"
  end

  create_table "beatmaps", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.bigint "online_id"
    t.float "star_difficulty"
    t.string "difficulty_name"
    t.bigint "max_combo"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "discord_exps", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "discord_server_id", null: false
    t.bigint "exp", default: 0, null: false
    t.json "detailed_exp", null: false
    t.integer "level", default: 0, null: false
    t.integer "message_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_server_id"], name: "index_discord_exps_on_discord_server_id"
    t.index ["player_id", "discord_server_id"], name: "uniq_player_exp_per_server", unique: true
    t.index ["player_id"], name: "index_discord_exps_on_player_id"
  end

  create_table "discord_servers", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "discord_id", null: false
    t.bigint "verified_role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "verification_log_channel_id"
    t.boolean "exp_enabled", default: false, null: false
    t.json "exp_roles_config"
    t.bigint "guest_role_id"
    t.timestamp "last_pruned"
    t.index ["discord_id"], name: "index_discord_servers_on_discord_id", unique: true
  end

  create_table "match_scores", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "match_id"
    t.bigint "player_id"
    t.bigint "beatmap_id"
    t.bigint "online_game_id"
    t.bigint "score"
    t.bigint "max_combo"
    t.bigint "count_50"
    t.bigint "count_100"
    t.bigint "count_300"
    t.bigint "count_miss"
    t.bigint "count_katu"
    t.bigint "count_geki"
    t.boolean "perfect"
    t.boolean "pass"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_full_combo"
    t.boolean "is_win"
    t.float "accuracy", null: false
    t.index ["player_id"], name: "index_match_scores_on_player"
  end

  create_table "match_teams", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.bigint "captain_id", null: false
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["captain_id"], name: "fk_rails_838189758e"
    t.index ["match_id"], name: "index_match_teams_on_match_id"
  end

  create_table "match_teams_players", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "match_team_id", null: false
    t.bigint "player_id", null: false
    t.index ["match_team_id", "player_id"], name: "index_match_teams_players_on_match_team_id_and_player_id", unique: true
  end

  create_table "matches", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "online_id"
    t.string "round_name"
    t.datetime "match_timestamp", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "tournament_id"
    t.bigint "winner_id"
    t.bigint "red_team_id"
    t.bigint "blue_team_id"
    t.index ["tournament_id"], name: "fk_rails_700eaa2935"
    t.index ["winner_id"], name: "fk_rails_9d0deeb219"
  end

  create_table "player_auths", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "uname", null: false
    t.json "raw"
    t.bigint "player_id", null: false
    t.string "provider", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_player_auths_on_player_id"
    t.index ["provider", "player_id", "uid"], name: "index_player_auths_on_provider_and_player_id_and_uid", unique: true
    t.index ["provider"], name: "index_player_auths_on_provider"
    t.index ["uid", "provider"], name: "unique_external_account", unique: true
  end

  create_table "players", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.bigint "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.bigint "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.bigint "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.bigint "invitations_count", default: 0
    t.integer "ban_status", default: 0, null: false
    t.string "country_code"
    t.string "avatar_url"
    t.json "ui_config", null: false
    t.index ["confirmation_token"], name: "index_players_on_confirmation_token", unique: true
    t.index ["email"], name: "index_players_on_email", unique: true
    t.index ["invitation_token"], name: "index_players_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_players_on_invitations_count"
    t.index ["invited_by_id"], name: "index_players_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_players_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_players_on_unlock_token", unique: true
  end

  create_table "tournaments", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "host_player_id"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["host_player_id"], name: "fk_rails_978fcfdc7f"
  end

  add_foreign_key "ban_histories", "players", column: "banned_by_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "ban_histories", "players", on_update: :cascade, on_delete: :cascade
  add_foreign_key "discord_exps", "discord_servers"
  add_foreign_key "discord_exps", "players", on_delete: :cascade
  add_foreign_key "match_teams", "matches"
  add_foreign_key "match_teams", "players", column: "captain_id"
  add_foreign_key "matches", "match_teams", column: "winner_id"
  add_foreign_key "matches", "tournaments", on_update: :cascade, on_delete: :cascade
  add_foreign_key "player_auths", "auth_providers", column: "provider", primary_key: "name"
  add_foreign_key "player_auths", "players", on_delete: :cascade
  add_foreign_key "tournaments", "players", column: "host_player_id", on_update: :cascade, on_delete: :nullify
end
