class ApplicationController < ActionController::Base
  before_action :authenticate

  private
  def authenticate
    if authenticate_with_http_basic { |u, p| p == ENV['SHIPYRD_API_KEY'] }
      true
    else
      request_http_basic_authentication
    end
  end
end
