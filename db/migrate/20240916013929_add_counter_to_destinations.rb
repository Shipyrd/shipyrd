class AddCounterToDestinations < ActiveRecord::Migration[7.2]
  def change
    add_column :destinations, :servers_count, :integer, default: 0
  end
end
