class AddWeeklyDeploySummaryToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :weekly_deploy_summary, :boolean, default: true, null: false
  end
end
