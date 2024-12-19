class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :event
      t.references :destination, null: false, foreign_key: true
      t.text :details
      t.references :channel, null: false, foreign_key: true
      t.datetime :notified_at

      t.timestamps
    end
  end
end
