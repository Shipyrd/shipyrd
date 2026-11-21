# Identity and entitlement in one request. The MCP server calls this to resolve a
# bearer token before it will serve any tool, so the whole auth decision lives
# here: 401 for a token it cannot place, 402 when no organization is paying, and
# otherwise the user plus the organizations that token can act on.
class MeController < ApplicationController
  before_action :ensure_json_format
  before_action :require_active_subscription

  def show
    @user = current_user
    @organizations = current_user.organizations.order(:name)
  end

  private

  def ensure_json_format
    return if request.format.json?

    render json: {error: "Only JSON format is supported"}, status: :not_acceptable
  end

  # Gated on the hosted app only. Community Edition has no subscription to check —
  # Organization#payment_required? returns false there outright — so self-hosters
  # are not paywalled out of their own API.
  def require_active_subscription
    return if community_edition?
    return if current_user.organizations.any?(&:active_subscription?)

    # billing_checkout_url, not billing_setup_url: `payment_required?` is false
    # during a trial, so BillingController#setup bounces a trial organization back
    # to the dashboard — and a trial is the common reason for landing here.
    # #checkout has no such guard and starts the Stripe session directly.
    render json: {
      error: "An active Shipyrd subscription is required.",
      billing_url: billing_checkout_url
    }, status: :payment_required
  end
end
