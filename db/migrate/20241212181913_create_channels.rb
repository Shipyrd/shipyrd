class CreateChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :channels do |t|
      t.integer :channel_type
      t.text :events
      t.references :owner, polymorphic: true
      t.references :application, null: false, foreign_key: true

      t.timestamps
    end
  end
end
