class AddCounterToDestinations < ActiveRecord::Migration[7.2]
  def change
    add_column :destinations, :servers_count, :integer, default: 0
    Destination.find_each do |destination|
      destination.update(servers_count: destination.servers.count)
    end
  end
end
