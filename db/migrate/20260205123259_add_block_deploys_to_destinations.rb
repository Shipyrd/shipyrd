class AddBlockDeploysToDestinations < ActiveRecord::Migration[8.1]
  def change
    add_column :destinations, :block_deploys, :boolean
  end
end
