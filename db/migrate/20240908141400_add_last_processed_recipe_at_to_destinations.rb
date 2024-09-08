class AddLastProcessedRecipeAtToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :recipe_last_processed_at, :datetime
  end
end
