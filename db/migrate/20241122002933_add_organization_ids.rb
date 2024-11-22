class AddOrganizationIds < ActiveRecord::Migration[7.2]
  def change
    add_column :applications, :organization_id, :bigint
    add_column :invite_links, :organization_id, :bigint
  end
end
