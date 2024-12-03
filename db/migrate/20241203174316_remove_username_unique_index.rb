class RemoveUsernameUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :username
    add_index :users, :username
  end
end
