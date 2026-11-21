class AddUniqueIndexToUsersToken < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :token, unique: true
  end
end
