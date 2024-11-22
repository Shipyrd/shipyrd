class CreateOrganizations < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :token
      t.integer :applications_count, default: 0
      t.integer :memberships_count, default: 0

      t.timestamps
    end
  end
end
