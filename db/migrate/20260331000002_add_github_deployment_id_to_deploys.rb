class AddGithubDeploymentIdToDeploys < ActiveRecord::Migration[8.0]
  def change
    add_column :deploys, :github_deployment_id, :bigint
  end
end
