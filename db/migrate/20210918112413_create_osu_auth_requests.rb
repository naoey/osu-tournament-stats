class CreateOsuAuthRequests < ActiveRecord::Migration[6.0]
  def up
    enable_extension('uuid-ossp')

    create_table :osu_auth_request do |t|
      t.string :nonce, null: false

      t.references :player, { foreign_key: true, null: false }
      t.references :discord_server, { foreign_key: true }

      t.timestamps
    end
  end

  def down
    drop_table :osu_auth_request

    disable_extension('uuid-ossp')
  end
end
