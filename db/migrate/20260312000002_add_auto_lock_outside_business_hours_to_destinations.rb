class AddAutoLockOutsideBusinessHoursToDestinations < ActiveRecord::Migration[8.1]
  def change
    add_column :destinations, :auto_lock_outside_business_hours, :boolean, default: false
  end
end
