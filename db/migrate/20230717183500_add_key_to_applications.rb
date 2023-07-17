class AddKeyToApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :applications, :key, :string
  end
end
