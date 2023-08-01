class AddRefToApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :applications, :branch, :string, default: "main"
  end
end
