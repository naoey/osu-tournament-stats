class AllowNullMatchWinner < ActiveRecord::Migration[6.0]
  def change
    change_column :matches, :winner_id, :integer, null: true
  end
end
