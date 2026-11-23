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

  def require_active_subscription
    return if community_edition?
    return if current_user.organizations.any?(&:active_subscription?)

    # Not billing_setup_url: #setup redirects organizations on trial back to the dashboard.
    render json: {
      error: "An active Shipyrd subscription is required.",
      billing_url: billing_checkout_url
    }, status: :payment_required
  end
end
