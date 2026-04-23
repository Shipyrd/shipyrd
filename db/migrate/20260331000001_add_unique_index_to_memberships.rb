class AddUniqueIndexToMemberships < ActiveRecord::Migration[7.2]
  def change
    add_index :memberships, [:user_id, :organization_id], unique: true
  end
end
