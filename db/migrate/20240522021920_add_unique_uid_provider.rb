class AddUniqueUidProvider < ActiveRecord::Migration[7.0]
  def change
    add_index :player_auths, %i[uid provider], unique: true, name: 'unique_external_account'

    remove_foreign_key :player_auths, column: :player_id
    add_foreign_key :player_auths, :players, column: :player_id, on_delete: :cascade

    remove_foreign_key :discord_exps, column: :player_id
    add_foreign_key :discord_exps, :players, column: :player_id, on_delete: :cascade
  end
end
