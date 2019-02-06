# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_06_040210) do

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

  create_table "matches", force: :cascade do |t|
    t.integer "online_id"
    t.integer "player_red_id"
    t.integer "player_blue_id"
    t.integer "winner"
    t.string "round_name"
    t.text "api_json"
    t.datetime "match_timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_blue_id"], name: "index_matches_on_player_blue_id"
    t.index ["player_red_id"], name: "index_matches_on_player_red_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
