class RenameIpToHostOnServers < ActiveRecord::Migration[7.1]
  def change
    rename_column :servers, :ip, :host
  end
end
