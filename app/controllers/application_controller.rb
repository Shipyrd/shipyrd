class ApplicationController < ActionController::Base
  before_action :authenticate

  private
  def authenticate
    if authenticate_with_http_basic { |u, p| ApiKey.exists?(token: p) }
      true
    else
      request_http_basic_authentication
    end
  end
end
