class OauthController < ApplicationController
  include Invitable

  skip_before_action :authenticate, if: -> { params[:provider] == "github" }
  skip_before_action :store_invite_code # oauth returns an auth code in params[:code]
  before_action :verify_provider, only: %i[authorize callback]
  before_action :set_current_application_id, only: %i[authorize]
  before_action :load_invite_link, only: %i[callback]

  def authorize
    auth_url = client.auth_code.authorize_url(
      scope: OauthToken::SCOPES[params[:provider].intern],
      state: oauth_session_state,
      redirect_uri: redirect_uri
    )

    redirect_to auth_url, allow_other_host: true
  end

  def callback
    raise "Invalid state" if oauth_session_state != params[:state]

    auth = OauthToken.create_from_oauth_token(
      provider: params[:provider],
      code: params[:code],
      application: current_application,
      user: current_user,
      organization: @invite_link&.organization,
      role: @invite_link&.role,
      redirect_uri: redirect_uri
    )

    if auth.user_token?
      session[:user_id] = auth.user.id
      redirect_to root_path
    else
      session[:current_application_id] = nil
      redirect_to edit_application_url(auth.application)
    end
  end

  private

  def redirect_uri
    oauth_callback_url(provider: params[:provider], host: ENV["SHIPYRD_HOST"], protocol: :https)
  end

  def verify_provider
    raise "Invalid provider" unless OauthToken.providers.key?(params[:provider])
  end

  def oauth_session_state
    session[:oauth_state] ||= SecureRandom.hex(32)
  end

  def set_current_application_id
    return unless current_organization

    session[:current_application_id] ||= current_organization.applications.find(params[:application_id]).id
  end

  def current_application
    return unless current_organization

    current_organization.applications.find(session[:current_application_id])
  end

  def client
    OauthToken.oauth2_client(params[:provider])
  end
end
