class ApplicationController < ActionController::Base
  rate_limit to: 60, within: 1.minute

  before_action :authenticate

  helper_method :current_user, :current_organization, :require_admin, :current_admin?, :community_edition?, :runners_enabled?

  def current_user
    return nil if cookies.signed[:user_id].blank?

    User.find_by(id: cookies.signed[:user_id])
  end

  def current_admin?
    return false if current_user.blank?

    current_organization.admin?(current_user)
  end

  def current_organization
    current_user.organizations.first
  end

  def require_admin
    redirect_to root_path unless current_admin?
  end

  def community_edition?
    ENV["COMMUNITY_EDITION"] != "0"
  end

  def runners_enabled?
    ENV["RUNNERS_ENABLED"] == "1"
  end

  private

  def authenticate
    if request.headers["Authorization"] && request.headers["Authorization"] =~ /^bearer/i
      session[:authenticated] = authenticate_with_http_token do |token, _options|
        @application = Application.find_by!(token: token)
      end
    elsif current_user.blank?
      redirect_to main_app.new_session_url
    end
  end
end
