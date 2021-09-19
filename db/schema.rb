# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_19_102754) do

  create_table "beatmaps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "online_id"
    t.float "star_difficulty"
    t.string "difficulty_name"
    t.bigint "max_combo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discord_servers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "discord_id", null: false
    t.bigint "registration_channel_id"
    t.bigint "verified_role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "verification_log_channel_id"
    t.index ["discord_id"], name: "index_discord_servers_on_discord_id", unique: true
  end

  create_table "match_scores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_full_combo"
    t.boolean "is_win"
    t.float "accuracy", null: false
    t.index ["player_id"], name: "index_match_scores_on_player"
  end

  create_table "match_teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "captain_id", null: false
    t.bigint "match_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["captain_id"], name: "fk_rails_838189758e"
    t.index ["match_id"], name: "index_match_teams_on_match_id"
  end

  create_table "match_teams_players", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "match_team_id", null: false
    t.bigint "player_id", null: false
    t.index ["match_team_id", "player_id"], name: "index_match_teams_players_on_match_team_id_and_player_id", unique: true
  end

  create_table "matches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "online_id"
    t.string "round_name"
    t.datetime "match_timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tournament_id"
    t.bigint "winner_id"
    t.bigint "red_team_id"
    t.bigint "blue_team_id"
    t.index ["tournament_id"], name: "fk_rails_700eaa2935"
    t.index ["winner_id"], name: "fk_rails_9d0deeb219"
  end

  create_table "osu_auth_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nonce", null: false
    t.boolean "resolved", default: false, null: false
    t.bigint "player_id", null: false
    t.bigint "discord_server_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discord_server_id"], name: "index_osu_auth_requests_on_discord_server_id"
    t.index ["player_id"], name: "index_osu_auth_requests_on_player_id"
  end

  create_table "players", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.bigint "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.bigint "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.bigint "invitations_count", default: 0
    t.bigint "osu_id"
    t.string "discord_id"
    t.datetime "discord_last_spoke"
    t.boolean "osu_verified", default: false
    t.index ["confirmation_token"], name: "index_players_on_confirmation_token", unique: true
    t.index ["email"], name: "index_players_on_email", unique: true
    t.index ["invitation_token"], name: "index_players_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_players_on_invitations_count"
    t.index ["invited_by_id"], name: "index_players_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_players_on_invited_by_type_and_invited_by_id"
    t.index ["osu_id"], name: "players_uniq_online_id", unique: true
    t.index ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_players_on_unlock_token", unique: true
  end

  create_table "tournaments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "host_player_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_player_id"], name: "fk_rails_978fcfdc7f"
  end

  add_foreign_key "match_teams", "matches"
  add_foreign_key "match_teams", "players", column: "captain_id"
  add_foreign_key "matches", "match_teams", column: "winner_id"
  add_foreign_key "matches", "tournaments", on_update: :cascade, on_delete: :cascade
  add_foreign_key "osu_auth_requests", "discord_servers"
  add_foreign_key "osu_auth_requests", "players"
  add_foreign_key "tournaments", "players", column: "host_player_id", on_update: :cascade, on_delete: :nullify
end
