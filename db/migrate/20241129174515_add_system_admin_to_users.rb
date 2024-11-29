class AddSystemAdminToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :system_admin, :boolean
  end
end
