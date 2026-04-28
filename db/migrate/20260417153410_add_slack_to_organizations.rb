class AddSlackToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :slack_team_id, :string
    add_column :organizations, :slack_team_name, :string
    add_column :organizations, :slack_access_token, :text

    add_index :organizations, :slack_team_id, unique: true
  end
end
