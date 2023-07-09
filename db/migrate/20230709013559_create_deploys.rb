class CreateDeploys < ActiveRecord::Migration[7.1]
  def change
    create_table :deploys do |t|
      t.datetime :deployed_at
      t.string :status
      t.string :deployer
      t.string :version
      t.string :service_version
      t.text :hosts
      t.string :command
      t.string :subcommand
      t.string :destination
      t.string :role
      t.integer :runtime

      t.timestamps
    end
  end
end
