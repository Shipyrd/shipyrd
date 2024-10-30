class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[new create]
  rate_limit to: -> { Rails.env.test? ? 1000 : 10 }, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.authenticate_by(auth_params.slice(:email, :password)))
      cookies.signed[:user_id] = user.id
      redirect_to root_path
    else
      redirect_to new_session_url, alert: "Invalid email and/or password."
    end
  end

  def destroy
    reset_session
    cookies.delete(:user_id)
    redirect_to new_session_url
  end

  private

  def auth_params
    params.permit(
      :email,
      :password,
      :authenticity_token,
      :commit
    )
  end
end
