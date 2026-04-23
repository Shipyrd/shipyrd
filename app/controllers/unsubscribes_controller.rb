class UnsubscribesController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :check_email_verification

  layout "unauthenticated"

  def show
    @user = User.find_by_token_for(:unsubscribe, params[:id])

    unless @user
      redirect_to root_path, alert: "Invalid or expired unsubscribe link."
    end
  end

  def update
    user = User.find_by_token_for(:unsubscribe, params[:id])

    if user
      user.update!(weekly_deploy_summary: false)
      redirect_to unsubscribe_path(params[:id]), notice: "You've been unsubscribed."
    else
      redirect_to root_path, alert: "Invalid or expired unsubscribe link."
    end
  end
end
