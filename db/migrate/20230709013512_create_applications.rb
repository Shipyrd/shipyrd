class CreateApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :url
      t.string :environment
      t.string :repository_url

      t.timestamps
    end
  end
end
