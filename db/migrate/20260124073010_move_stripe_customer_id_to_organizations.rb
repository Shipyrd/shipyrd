class MoveStripeCustomerIdToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :stripe_customer_id, :string
    add_index :organizations, :stripe_customer_id
  end
end
