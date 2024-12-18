class CreateChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :channels do |t|
      t.integer :channel_type
      t.text :events
      t.string :owner_type
      t.integer :owner_id
      t.integer :oauth_token_id
      t.references :application, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :channels, [:owner_type, :owner_id]
    add_index :channels, :oauth_token_id
  end
end
