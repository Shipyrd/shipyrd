# frozen_string_literal: true

class CreateCompactChannel < ActiveRecord::Migration[7.2]
  def change
    # standard:disable Rails/ReversibleMigration
    change_column :solid_cable_messages, :channel, :binary, limit: 1024, null: false
    add_column :solid_cable_messages, :channel_hash, :integer, limit: 8, if_not_exists: true
    add_index :solid_cable_messages, :channel_hash, if_not_exists: true
    change_column :solid_cable_messages, :payload, :binary, limit: 536_870_912, null: false

    SolidCable::Message.destroy_all
    # standard:enable Rails/ReversibleMigration
  end
end
