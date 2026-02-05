class CreateStripeCustomerJob < ApplicationJob
  def perform(membership_id)
    Membership.find(membership_id).create_stripe_customer
  end
end
