class AddAdditionalUserFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_digest
    end
  end
end
