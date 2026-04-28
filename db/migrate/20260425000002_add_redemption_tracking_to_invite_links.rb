class AddRedemptionTrackingToInviteLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :invite_links, :redeemed_at, :datetime
    add_column :invite_links, :redeemed_by_user_id, :bigint

    add_index :invite_links, :redeemed_by_user_id
    add_foreign_key :invite_links, :users, column: :redeemed_by_user_id
  end
end
