class CreateServers < ActiveRecord::Migration[7.1]
  def change
    create_table :servers do |t|
      t.references :destination, null: false, foreign_key: true
      t.string :ip

      t.timestamps
      t.index [:destination_id, :ip], unique: true
    end
  end
end
