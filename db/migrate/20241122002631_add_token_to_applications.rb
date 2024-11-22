class AddTokenToApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :applications, :token, :string
  end
end
