class CreateInviteLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :invite_links do |t|
      t.datetime :expires_at
      t.datetime :deactivated_at
      t.integer :role
      t.string :code
      t.references :creator, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :invite_links, :code, unique: true
  end
end
