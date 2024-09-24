class ApplicationController < ActionController::Base
  rate_limit to: 30, within: 1.minute

  before_action :authenticate

  private

  def authenticate
    if request.headers["Authorization"] && request.headers["Authorization"] =~ /^bearer/i
      session[:authenticated] = authenticate_with_http_token do |token, _options|
        ApiKey.exists?(token: token)
      end
    elsif authenticate_with_http_basic { |u, p| p.present? && ApiKey.exists?(token: p) }
      true
    else
      request_http_basic_authentication
    end
  end
end
