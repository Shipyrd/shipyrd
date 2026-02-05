class SetupStripeSubscriptions < ActiveRecord::Migration[8.1]
  def change
    Organization.where(stripe_customer_id: nil).find_each do |organization|
      admin = organization.memberships.admin.first

      next unless admin

      admin.enqueue_create_stripe_customer
    end
  end
end
