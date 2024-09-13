class CreateRunners < ActiveRecord::Migration[7.1]
  def change
    create_table :runners do |t|
      t.integer :server_id
      t.integer :destination_id
      t.string :command
      t.string :full_command
      t.text :output
      t.text :error
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
