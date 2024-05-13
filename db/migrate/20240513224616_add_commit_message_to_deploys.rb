class AddCommitMessageToDeploys < ActiveRecord::Migration[7.1]
  def change
    add_column :deploys, :commit_message, :string
  end
end
