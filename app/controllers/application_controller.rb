class ApplicationController < ActionController::Base
  before_action :authenticate

  helper_method :current_user

  def current_user
    return nil if cookies.signed[:user_id].blank?

    User.find(cookies.signed[:user_id])
  end

  private

  def authenticate
    if request.headers["Authorization"] && request.headers["Authorization"] =~ /^bearer/i
      session[:authenticated] = authenticate_with_http_token do |token, _options|
        ApiKey.exists?(token: token)
      end
    else
      unless current_user.present?
        redirect_to new_session_url
      end
    end
  end
end
