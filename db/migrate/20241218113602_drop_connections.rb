class DropConnections < ActiveRecord::Migration[8.0]
  def up
    drop_table :connections, if_exists: true
  end

  def down
    create_table "connections" do |t|
      t.integer "provider"
      t.text "key"
      t.datetime "last_connected_at"
      t.bigint "application_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["application_id"], name: "index_connections_on_application_id"
    end
  end
end
