class CreateOauthTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :oauth_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.references :application, null: false, foreign_key: true
      t.integer :provider
      t.text :token
      t.text :refresh_token
      t.datetime :expires_at
      t.string :scope
      t.text :extra_data
      t.timestamps
    end
  end
end
