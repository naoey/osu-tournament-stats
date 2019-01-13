class CreateMatchScores < ActiveRecord::Migration[5.2]
  def change
    create_table :match_scores do |t|
      t.integer :match_id
      t.integer :player_id
      t.integer :beatmap_id
      t.integer :online_game_id
      t.integer :score
      t.integer :max_combo
      t.integer :count_50
      t.integer :count_100
      t.integer :count_300
      t.integer :count_miss
      t.integer :count_katu
      t.integer :count_geki
      t.boolean :perfect
      t.boolean :pass

      t.timestamps
    end

    add_index "match_scores", ["player_id"], name: "index_match_scores_on_player", using: :btree
  end
end
