class AllowNullMatchWinner < ActiveRecord::Migration[6.0]
  def up
    change_column :matches, :winner_id, :integer, null: true

    add_index :players, :osu_id, unique: true, name: 'players_uniq_online_id'
  end

  def down
    change_column :matches, :winner_id, :integer, null: false

    remove_index :players, name: 'players_uniq_online_id'
  end
end
