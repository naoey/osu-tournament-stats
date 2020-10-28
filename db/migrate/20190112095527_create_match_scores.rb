class CreateMatchScores < ActiveRecord::Migration[5.2]
  def change
    create_table :match_scores do |t|
      t.bigint :match_id
      t.bigint :player_id
      t.bigint :beatmap_id
      t.bigint :online_game_id
      t.bigint :score
      t.bigint :max_combo
      t.bigint :count_50
      t.bigint :count_100
      t.bigint :count_300
      t.bigint :count_miss
      t.bigint :count_katu
      t.bigint :count_geki
      t.boolean :perfect
      t.boolean :pass

      t.timestamps
    end

    add_index "match_scores", ["player_id"], name: "index_match_scores_on_player", using: :btree
  end
end
