class AddEmailVerifiedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_verified_at, :datetime

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE users
          SET email_verified_at = users.created_at
          WHERE users.id IN (
            SELECT DISTINCT user_id FROM oauth_tokens WHERE provider = 0
          )
        SQL
      end
    end
  end
end
