class AddBadgeKeyToApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :applications, :badge_key, :string

    Application.all.find_each(&:regenerate_badge_key)
  end
end
