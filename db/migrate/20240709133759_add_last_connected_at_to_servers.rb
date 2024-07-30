class AddLastConnectedAtToServers < ActiveRecord::Migration[7.1]
  def change
    add_column :servers, :last_connected_at, :datetime
  end
end
