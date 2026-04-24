class OauthController < ApplicationController
  include Invitable

  skip_before_action :authenticate, if: -> { params[:provider] == "github" }
  skip_before_action :check_email_verification
  skip_before_action :store_invite_code # oauth returns an auth code in params[:code]
  before_action :verify_provider, only: %i[authorize callback]
  before_action :require_admin, if: -> { params[:provider] == "slack_bot" }, only: %i[authorize callback]
  before_action :set_current_application_id, only: %i[authorize]
  before_action :load_invite_link, only: %i[callback]

  def authorize
    rotate_oauth_state!

    auth_url = client.auth_code.authorize_url(
      scope: OauthToken::SCOPES[params[:provider].intern],
      state: oauth_session_state,
      redirect_uri: redirect_uri
    )

    redirect_to auth_url, allow_other_host: true
  end

  def callback
    expected_state = oauth_session_state
    session.delete(:oauth_state)
    raise "Invalid state" if expected_state.blank? || expected_state != params[:state]

    return handle_slack_bot_callback if params[:provider] == "slack_bot"

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

  ALLOWED_PROVIDERS = (OauthToken.providers.keys + %w[slack_bot]).freeze

  def verify_provider
    raise "Invalid provider" unless ALLOWED_PROVIDERS.include?(params[:provider])
  end

  def oauth_session_state
    session[:oauth_state]
  end

  def rotate_oauth_state!
    session[:oauth_state] = SecureRandom.hex(32)
  end

  def set_current_application_id
    return unless current_organization
    return if params[:application_id].blank?

    session[:current_application_id] ||= current_organization.applications.find(params[:application_id]).id
  end

  def handle_slack_bot_callback
    token = OauthToken.oauth2_client("slack_bot").auth_code.get_token(
      params[:code],
      redirect_uri: redirect_uri
    )

    team_id = token.params.dig("team", "id")
    team_name = token.params.dig("team", "name")

    if team_id.blank?
      return redirect_to edit_organization_url(current_organization),
        alert: "Slack did not return a workspace id. Please try again."
    end

    current_organization.update!(
      slack_team_id: team_id,
      slack_team_name: team_name,
      slack_access_token: token.token
    )

    redirect_to edit_organization_url(current_organization),
      notice: "Slack workspace \"#{team_name}\" connected."
  rescue ActiveRecord::RecordNotUnique
    redirect_to edit_organization_url(current_organization),
      alert: "This Slack workspace is already connected to another organization. Uninstall Shipyrd from the Slack workspace before retrying so the issued bot token is revoked."
  end

  def current_application
    return unless current_organization

    current_organization.applications.find(session[:current_application_id])
  end

  def client
    OauthToken.oauth2_client(params[:provider])
  end
end
