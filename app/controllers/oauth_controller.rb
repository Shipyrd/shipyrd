class OauthController < ApplicationController
  include Invitable

  skip_before_action :authenticate, if: -> { params[:provider] == "github" }
  skip_before_action :check_email_verification
  skip_before_action :store_invite_code # oauth returns an auth code in params[:code]
  before_action :verify_provider, only: %i[authorize callback]
  before_action :set_current_application_id, only: %i[authorize]
  before_action :load_invite_link, only: %i[callback]

  def authorize
    set_current_application_id if params[:provider] == "github" && params[:application_id].present?

    auth_url = if github_app_install?
      "https://github.com/apps/#{ENV["SHIPYRD_GITHUB_APP_SLUG"]}/installations/new?state=#{oauth_session_state}"
    else
      client.auth_code.authorize_url(
        scope: OauthToken::SCOPES[params[:provider].intern],
        state: oauth_session_state,
        redirect_uri: redirect_uri
      )
    end

    redirect_to auth_url, allow_other_host: true
  end

  def callback
    raise "Invalid state" if oauth_session_state != params[:state]

    if params[:installation_id]
      handle_github_app_installation
    else
      handle_oauth_token
    end
  end

  private

  def handle_github_app_installation
    application = current_organization.applications.find(session.delete(:current_application_id))
    installation_id = params[:installation_id]
    repositories = GithubAppClient.installation_repositories(installation_id)

    if repositories.nil?
      redirect_to edit_application_url(application), alert: "GitHub App installation could not be verified."
      return
    end

    github_installation = application.github_installation || application.build_github_installation
    github_installation.update!(installation_id: installation_id)

    if application.matches_github_repository?(repositories)
      redirect_to edit_application_url(application), notice: "GitHub App connected."
    else
      redirect_to application_github_url(application)
    end
  end

  def handle_oauth_token
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

  def redirect_uri
    oauth_callback_url(provider: params[:provider], host: ENV["SHIPYRD_HOST"], protocol: ENV.fetch("SHIPYRD_PROTOCOL", "https"))
  end

  def verify_provider
    raise "Invalid provider" unless OauthToken.providers.key?(params[:provider])
  end

  def github_app_install?
    params[:provider] == "github" &&
      params[:application_id].present? &&
      ENV["SHIPYRD_GITHUB_APP_SLUG"].present?
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
