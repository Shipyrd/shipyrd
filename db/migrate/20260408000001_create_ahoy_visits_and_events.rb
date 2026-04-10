class CreateAhoyVisitsAndEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :ahoy_visits do |t|
      t.string :visit_token
      t.string :visitor_token

      t.references :user

      t.datetime :started_at
    end

    add_index :ahoy_visits, :visit_token, unique: true
    add_index :ahoy_visits, [:visitor_token, :started_at]

    create_table :ahoy_events do |t|
      t.references :visit
      t.references :user

      t.string :name
      t.json :properties
      t.datetime :time
    end

    add_index :ahoy_events, [:name, :time]
  end
end
