class AddOrganizationToChannels < ActiveRecord::Migration[8.0]
  def change
    add_reference :channels, :organization, null: false, foreign_key: true
  end
end
