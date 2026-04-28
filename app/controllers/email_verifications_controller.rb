class EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: :show
  skip_before_action :check_email_verification
  before_action :no_referrer, only: :show

  rate_limit to: 3, within: 1.hour, only: :create, with: -> { redirect_to new_email_verification_url, alert: "Try again later." }

  def new
  end

  def show
    user = User.find_by_token_for(:email_verification, params[:id])

    if user && !user.email_verified?
      user.update!(email_verified_at: Time.current)
      redirect_to root_path, notice: "Email verified!"
    else
      redirect_to new_session_path, alert: "Verification link is invalid or has expired."
    end
  end

  def create
    UserMailer.email_verification(current_user).deliver_later
    redirect_to new_email_verification_path, notice: "Verification email sent. Check your inbox."
  end

  private

  # The verification token sits in the URL; this stops the browser from
  # leaking it via the Referer header when the post-verify redirect loads
  # third-party assets.
  def no_referrer
    response.headers["Referrer-Policy"] = "no-referrer"
  end
end
