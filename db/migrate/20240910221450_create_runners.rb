class CreateRunners < ActiveRecord::Migration[7.1]
  def change
    create_table :runners do |t|
      t.bigint :server_id
      t.bigint :destination_id
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
