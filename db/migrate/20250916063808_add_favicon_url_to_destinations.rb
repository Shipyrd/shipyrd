class AddFaviconUrlToDestinations < ActiveRecord::Migration[8.0]
  def change
    add_column :destinations, :favicon_url, :string
  end
end