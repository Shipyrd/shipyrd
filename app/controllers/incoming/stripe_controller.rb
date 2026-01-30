class Incoming::StripeController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate

  def create
    payload = request.body.read
    sig_header = request.env["SHIPYRD_STRIPE_HTTP_SIGNATURE"]
    endpoint_secret = ENV["SHIPYRD_STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError
      head :unauthorized
      return
    end

    customer_id = nil
    subscription_id = nil

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      customer_id = session.customer
      subscription_id = session.subscription
    when "customer.subscription.created", "customer.subscription.updated", "customer.subscription.deleted"
      subscription = event.data.object
      customer_id = subscription.customer
      subscription_id = subscription.id
    when "invoice.payment_succeeded"
      invoice = event.data.object
      subscription_id = invoice.subscription
    end

    organization = if customer_id
      Organization.find_by!(stripe_customer_id: customer_id)
    elsif subscription_id
      Organization.find_by!(stripe_subscription_id: subscription_id)
    end

    return head :ok unless organization

    case event.type
    when "checkout.session.completed"
      if subscription_id
        subscription = Stripe::Subscription.retrieve(subscription_id)
        organization.update!(
          stripe_subscription_id: subscription.id,
          stripe_subscription_status: subscription.status
        )
      end
    when "customer.subscription.created", "customer.subscription.updated", "customer.subscription.deleted"
      organization.update!(
        stripe_subscription_id: subscription_id,
        stripe_subscription_status: event.data.object.status
      )
    when "invoice.payment_succeeded"
      organization.update!(last_payment_at: Time.zone.at(event.data.object.created))
    end

    head :ok
  end
end
