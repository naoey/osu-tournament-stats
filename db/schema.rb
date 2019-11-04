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

ActiveRecord::Schema.define(version: 2019_10_21_115719) do

  create_table "beatmaps", force: :cascade do |t|
    t.string "name"
    t.integer "online_id"
    t.float "star_difficulty"
    t.string "difficulty_name"
    t.integer "max_combo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "match_scores", force: :cascade do |t|
    t.integer "match_id"
    t.integer "player_id"
    t.integer "beatmap_id"
    t.integer "online_game_id"
    t.integer "score"
    t.integer "max_combo"
    t.integer "count_50"
    t.integer "count_100"
    t.integer "count_300"
    t.integer "count_miss"
    t.integer "count_katu"
    t.integer "count_geki"
    t.boolean "perfect"
    t.boolean "pass"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_match_scores_on_player"
  end

  create_table "match_teams", force: :cascade do |t|
    t.string "name"
    t.integer "captain_id", null: false
    t.integer "match_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_id"], name: "index_match_teams_on_match_id"
  end

  create_table "match_teams_players", force: :cascade do |t|
    t.integer "match_team_id", null: false
    t.integer "player_id", null: false
    t.index ["match_team_id", "player_id"], name: "index_match_teams_players_on_match_team_id_and_player_id", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.integer "online_id"
    t.string "round_name"
    t.datetime "match_timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tournament_id"
    t.integer "winner_id"
    t.integer "red_team_id"
    t.integer "blue_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "osu_id"
    t.string "discord_id"
    t.datetime "discord_last_spoke"
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

  create_table "tournaments", force: :cascade do |t|
    t.string "name", null: false
    t.integer "host_player_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "match_teams", "players", column: "captain_id"
  add_foreign_key "matches", "match_teams", column: "winner_id", on_delete: :restrict
  add_foreign_key "matches", "tournaments", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tournaments", "players", column: "host_player_id", on_update: :cascade, on_delete: :nullify
end
