class AddBannedStatusToPlayer < ActiveRecord::Migration[6.0]
  def up
    add_column :players, :ban_status, :integer, null: false, default: 0

    create_table :ban_histories do |t|
      t.references :player, foreign_key: { to_table: :players, on_update: :cascade, on_delete: :cascade }, null: false
      t.references :banned_by, foreign_key: { to_table: :players, on_update: :cascade, on_delete: :nullify }, null: true
      t.integer :ban_type, default: 0, null: false
      t.string :reason, null: true
      t.timestamps
    end
  end

  def down
    remove_column :players, :ban_status
    drop_table :ban_histories
  end
end
