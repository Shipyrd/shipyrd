class RemoveKeysFromDestinations < ActiveRecord::Migration[8.0]
  def change
    remove_column :destinations, :public_key, :text, if_exists: true
    remove_column :destinations, :private_key, :text, if_exists: true
  end
end
