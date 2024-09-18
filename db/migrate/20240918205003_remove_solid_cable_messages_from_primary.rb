class RemoveSolidCableMessagesFromPrimary < ActiveRecord::Migration[7.2]
  def change
    drop_table :solid_cable_messages, if_exists: true
  end
end
