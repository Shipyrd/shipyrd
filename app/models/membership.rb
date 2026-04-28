class Membership < ApplicationRecord
  include Role

  belongs_to :user
  belongs_to :organization, counter_cache: :users_count

  validates :user_id, uniqueness: {scope: :organization_id}

  after_create :enqueue_create_stripe_customer, if: :admin?

  def enqueue_create_stripe_customer
    CreateStripeCustomerJob.perform_later(id)
  end

  def create_stripe_customer
    return false if ENV["COMMUNITY_EDITION"] != "0"
    return unless Stripe.api_key.present?
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
