class ApplicationController < ActionController::Base
  rate_limit to: 60, within: 1.minute

  before_action :authenticate

  helper_method :current_user, :current_organization, :require_admin, :current_admin?, :community_edition?

  def current_user
    # Check for API user first (set by API authentication)
    return @current_api_user if @current_api_user

    # Fall back to session-based authentication
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

  private

  def authenticate
    if request.headers["Authorization"] && request.headers["Authorization"] =~ /^bearer/i
      authenticate_with_http_token do |token, _options|
        case controller_name
        when "deploys"
          authenticate_with_application_token(token)
        else
          authenticate_with_user_token(token)
        end
      end
    elsif current_user.blank?
      if request.format.json?
        render json: {error: "Authorization token required"}, status: :unauthorized
      else
        redirect_to main_app.new_session_url
      end
    end
  end

  def authenticate_with_application_token(token)
    @application = Application.find_by!(token: token)
  rescue ActiveRecord::RecordNotFound
    render json: {error: "Invalid token"}, status: :unauthorized
  end

  def authenticate_with_user_token(token)
    @current_api_user = User.find_by!(token: token)
  rescue ActiveRecord::RecordNotFound
    render json: {error: "Invalid token"}, status: :unauthorized
  end
end
