class FixMatchPlayerColumnNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :matches, :player_red, :player_red_id
    rename_column :matches, :player_blue, :player_blue_id
  end
end
