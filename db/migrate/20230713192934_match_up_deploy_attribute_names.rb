class MatchUpDeployAttributeNames < ActiveRecord::Migration[7.1]
  def change
    rename_column :deploys, :deployed_at, :recorded_at
    rename_column :deploys, :deployer, :performer
  end
end
