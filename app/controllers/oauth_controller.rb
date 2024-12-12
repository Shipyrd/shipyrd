class OauthController < ApplicationController
  before_action :set_current_application_id, only: %i[authorize]

  def authorize
    auth_url = client.auth_code.authorize_url(
      scope: OauthToken::SCOPES[params[:provider]],
      state: oauth_session_state,
      redirect_uri: oauth_callback_url(provider: params[:provider], host: ENV["SHIPYRD_HOST"], protocol: :https)
    )

    redirect_to auth_url, allow_other_host: true
  end

  def callback
    raise "Invalid state" if oauth_session_state != params[:state]

    auth = OauthToken.create_from_oauth_token(
      provider: params[:provider],
      code: params[:code],
      application: current_application,
      user: current_user
    )

    session[:current_application_id] = nil

    redirect_to edit_application_url(auth.application)
  end

  private

  def oauth_session_state
    session[:oauth_state] ||= SecureRandom.hex(32)
  end

  def set_current_application_id
    session[:current_application_id] ||= current_organization.applications.find(params[:application_id]).id
  end

  def current_application
    current_organization.applications.find(session[:current_application_id])
  end

  def client
    OauthToken.oauth2_client(params[:provider])
  end
end
