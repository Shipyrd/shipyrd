class AddLockDetailsToDestinations < ActiveRecord::Migration[8.0]
  def change
    add_column :destinations, :locked_at, :datetime
    add_column :destinations, :locked_by_user_id, :integer
  end
end
