class AddGithubInstallationIdToApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :applications, :github_installation_id, :bigint
  end
end
