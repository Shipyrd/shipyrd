class AddServiceToDeploys < ActiveRecord::Migration[7.1]
  def change
    add_column :deploys, :service, :string
  end
end
