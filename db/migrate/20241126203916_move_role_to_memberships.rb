class MoveRoleToMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :memberships, :role, :integer, default: 0
    remove_column :users, :role, :integer
    rename_column :organizations, :memberships_count, :users_count
  end
end
