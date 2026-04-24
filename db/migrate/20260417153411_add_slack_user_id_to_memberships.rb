class AddSlackUserIdToMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :memberships, :slack_user_id, :string

    add_index :memberships, [:organization_id, :slack_user_id], unique: true
  end
end
