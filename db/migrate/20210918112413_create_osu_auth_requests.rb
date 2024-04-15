class CreateOsuAuthRequests < ActiveRecord::Migration[6.0]
  def up
    enable_extension("uuid-ossp")

    create_table :osu_auth_requests do |t|
      t.string :nonce, null: false
      t.boolean :resolved, null: false, default: false

      t.references :player, { foreign_key: true, null: false }
      t.references :discord_server, { foreign_key: true }

      t.timestamps
    end

    add_column :players, :osu_verified, :boolean, default: false
  end

  def down
    drop_table :osu_auth_requests

    remove_column :players, :osu_verified
  end
end
