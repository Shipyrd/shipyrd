class AddRecipeUpdatedAtToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :recipe_updated_at, :datetime
  end
end
