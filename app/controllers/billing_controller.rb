class BillingController < ApplicationController
  def setup
    redirect_to root_path unless current_organization.payment_required?
  end

  def checkout
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
