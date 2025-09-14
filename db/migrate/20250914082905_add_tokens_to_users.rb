class AddTokensToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :token, :string
  end
end
