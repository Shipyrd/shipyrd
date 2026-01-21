class AddServiceToApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :applications, :service, :string
  end
end
