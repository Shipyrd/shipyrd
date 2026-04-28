class AddGithubDeploymentIdToDeploys < ActiveRecord::Migration[8.1]
  def change
    add_column :deploys, :github_deployment_id, :bigint
  end
end
