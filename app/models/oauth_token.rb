class OauthToken < ApplicationRecord
  encrypts :token
  encrypts :refresh_token
  encrypts :extra_data

  belongs_to :user
  belongs_to :application, optional: true
  has_one :channel, as: :owner, dependent: :destroy

  enum :provider, {
    github: 0,
    slack: 1
  }

  serialize :extra_data, coder: JSON

  after_create :create_channel

  SCOPES = {
    slack: "identify,incoming-webhook,chat:write:bot"
  }

  def user_token?
    user.present? && application.blank?
  end

  def create_channel
    return unless application

    create_channel!(
      application: application,
      channel_type: provider,
      events: Channel::EVENTS
    )
  end

  def notify(event, details)
    if provider == "slack"
      Slack.new(token).notify(
        event,
        details.merge(
          channel_id: extra_data["channel_id"]
        )
      )
    end
  end

  def self.configured_providers
    providers.keys.select do |provider|
      config = provider_configuration(provider)

      next unless config

      config[:client_id].present? && config[:client_secret].present?
    end
  end

  def self.oauth2_client(provider)
    config = provider_configuration(provider)

    OAuth2::Client.new(
      config[:client_id],
      config[:client_secret],
      config.slice(:site, :authorize_url, :token_url)
    )
  end

  def self.create_from_oauth_token(provider:, code:, redirect_uri:, application: nil, user: nil, organization: nil, role: nil)
    token = oauth2_client(provider).auth_code.get_token(
      code,
      redirect_uri: redirect_uri
    )

    user = create_user_from_provider(provider: provider, token: token.token, organization: organization, role: role) if user.nil?

    create!(
      provider: provider,
      application: application,
      user: user,
      token: token.token,
      refresh_token: token.refresh_token,
      scope: token.params["scope"],
      extra_data: provider_extra_data(provider, token.params)
    )
  end

  def self.create_user_from_provider(provider:, token:, organization:, role:)
    case provider
    when "github"
      github = Octokit::Client.new(access_token: token)
      github_user = github.user
      github_emails = github.emails

      user = User.find_or_create_by!(email: github_user.email) do |u|
        u.username = "https://github.com/#{github_user.login}"
        u.avatar_url = "#{github_user.avatar_url}&s=100"
        u.name = github_user.name
      end

      if organization
        organization.memberships.create(
          user: user,
          role: role
        )
      elsif user.memberships.empty?
        organization = Organization.create!(name: user.name)
        user.memberships.create(
          organization: organization,
          role: :admin
        )
      end

      github_emails.each do |email|
        next unless email[:verified]
        next if /noreply\.github\.com/.match?(email[:email])

        user.email_addresses.find_or_create_by!(email: email[:email])
      end

      user
    else
      raise "Unknown provider for user creation"
    end
  end

  def self.provider_configuration(provider)
    case provider
    when "slack"
      {
        client_id: ENV["SHIPYRD_SLACK_CLIENT_ID"],
        client_secret: ENV["SHIPYRD_SLACK_SECRET"],
        site: "https://slack.com",
        token_url: "/api/oauth.access"
      }
    when "github"
      {
        client_id: ENV["SHIPYRD_GITHUB_CLIENT_ID"],
        client_secret: ENV["SHIPYRD_GITHUB_SECRET"],
        site: "https://github.com",
        authorize_url: "/login/oauth/authorize",
        token_url: "/login/oauth/access_token"
      }
    end
  end

  def self.provider_extra_data(provider, params)
    case provider
    when "slack"
      webhook = params["incoming_webhook"]

      {
        channel_id: webhook["channel_id"],
        channel_name: webhook["channel"],
        url: webhook["url"],
        configuration_url: webhook["configuration_url"],
        team_id: params["team_id"],
        team_name: params["team_name"]
      }
    end
  end
end
