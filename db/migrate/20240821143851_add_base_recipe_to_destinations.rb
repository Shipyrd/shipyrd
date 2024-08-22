class AddBaseRecipeToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :base_recipe, :text
  end
end
