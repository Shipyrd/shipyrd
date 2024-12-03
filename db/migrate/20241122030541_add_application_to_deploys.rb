class AddApplicationToDeploys < ActiveRecord::Migration[7.2]
  def change
    add_column :deploys, :application_id, :bigint, null: false
    add_index :deploys, :application_id
  end
end
