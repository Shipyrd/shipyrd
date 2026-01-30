class BillingController < ApplicationController
  def setup
    redirect_to root_path unless current_organization.payment_required?
  end

  def checkout
    if current_organization.stripe_customer_id.blank?
      customer = Stripe::Customer.create(
        email: current_user.email,
        metadata: {
          organization_id: current_organization.id
        }
      )
      current_organization.update!(stripe_customer_id: customer.id)
    end

    session = Stripe::Checkout::Session.create(
      customer: current_organization.stripe_customer_id,
      mode: "subscription",
      success_url: root_url,
      cancel_url: root_url,
      allow_promotion_codes: true,
      line_items: [{
        price: ENV["SHIPYRD_STRIPE_PRICE_ID"],
        quantity: 1
      }]
    )

    redirect_to session.url, allow_other_host: true
  end
end
