class ApplicationController < ActionController::Base
  before_action :authenticate

  helper_method :current_user, :require_admin

  def current_user
    return nil if cookies.signed[:user_id].blank?

    User.find_by(id: cookies.signed[:user_id])
  end

  def require_admin
    redirect_to root_path unless current_user.admin?
  end

  private

  def authenticate
    if request.headers["Authorization"] && request.headers["Authorization"] =~ /^bearer/i
      session[:authenticated] = authenticate_with_http_token do |token, _options|
        ApiKey.exists?(token: token)
      end
    elsif User.has_password.count > 0
      redirect_to new_session_url if current_user.blank?
    elsif authenticate_with_http_basic { |u, p| p.present? && ApiKey.exists?(token: p) }
      true
    else
      request_http_basic_authentication
    end
  end
end
