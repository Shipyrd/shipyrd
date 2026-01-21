class CreateIncomingWebhooks < ActiveRecord::Migration[8.1]
  def change
    create_table :incoming_webhooks do |t|
      t.integer :provider
      t.references :application, null: false, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
