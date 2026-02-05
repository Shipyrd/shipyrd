class Membership < ApplicationRecord
  include Role

  belongs_to :user
  belongs_to :organization, counter_cache: :users_count

  after_create :enqueue_create_stripe_customer, if: :admin?

  def enqueue_create_stripe_customer
    CreateStripeCustomerJob.perform_later(id)
  end

  def create_stripe_customer
    return if organization.stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: user.email,
      metadata: {
        organization_id: organization.id
      }
    )

    organization.update(stripe_customer_id: customer.id)
  end
end
