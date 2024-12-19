class AddIndicesForNotifications < ActiveRecord::Migration[8.0]
  def change
    # For deploy notifications looking up destination by name
    add_index :destinations, [:application_id, :name]
  end
end
