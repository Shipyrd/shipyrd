class CreateEmailAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.references :user, null: false, foreign_key: true

      t.timestamps
      t.index :email
    end

    User.all.find_each do |user|
      user.send(:store_email_address)
    end
  end
end
