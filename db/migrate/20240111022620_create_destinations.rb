class CreateDestinations < ActiveRecord::Migration[7.1]
  def change
    remove_column :applications, :url, :string
    remove_column :applications, :environment, :string
    remove_column :applications, :branch, :string

    create_table :destinations do |t|
      t.string :url
      t.string :name
      t.string :branch, default: "main"
      t.references :application, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
