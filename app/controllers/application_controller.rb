class ApplicationController < ActionController::Base
  before_action :authenticate

  helper_method :current_user, :current_organization, :require_admin

  def current_user
    return nil if cookies.signed[:user_id].blank?

    User.find_by(id: cookies.signed[:user_id])
  end

  def current_organization
    current_user.organizations.first
  end

  def require_admin
    redirect_to root_path unless current_user.admin?
  end

  private

  def authenticate
    if request.headers["Authorization"] && request.headers["Authorization"] =~ /^bearer/i
      session[:authenticated] = authenticate_with_http_token do |token, _options|
        @application = Application.find_by(token: token)
      end
    elsif current_user.blank?
      redirect_to new_session_url
    end
  end
end
