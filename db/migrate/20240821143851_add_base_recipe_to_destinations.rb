class AddBaseRecipeToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :base_recipe, :text
    add_column :destinations, :recipe, :text
  end
end
