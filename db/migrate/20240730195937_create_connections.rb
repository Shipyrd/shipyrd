class CreateConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :connections do |t|
      t.integer :provider
      t.text :key
      t.datetime :last_connected_at
      t.references :application, null: false, foreign_key: true

      t.timestamps
    end
  end
end
