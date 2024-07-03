class AddKeysToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :public_key, :text
    add_column :destinations, :private_key, :text
  end
end
