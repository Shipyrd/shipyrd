class AddSortOrderToApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :applications, :sort_order, :integer, default: 0, null: false
  end
end
