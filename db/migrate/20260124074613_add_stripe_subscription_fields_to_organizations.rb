class AddStripeSubscriptionFieldsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :stripe_subscription_id, :string
    add_column :organizations, :stripe_subscription_status, :string
    add_column :organizations, :last_payment_at, :datetime
    add_index :organizations, :stripe_subscription_id
  end
end
