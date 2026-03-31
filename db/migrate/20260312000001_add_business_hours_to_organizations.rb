class AddBusinessHoursToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :time_zone, :string
    add_column :organizations, :business_hours_start, :integer, default: 9
    add_column :organizations, :business_hours_end, :integer, default: 17
  end
end
