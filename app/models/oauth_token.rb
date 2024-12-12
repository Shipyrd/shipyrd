class OauthToken < ApplicationRecord
  encrypts :token
  encrypts :refresh_token
  encrypts :extra_data

  belongs_to :user
  belongs_to :organization
  belongs_to :application

  enum :provider, {
    github: 0,
    slack: 1
  }

  serialize :extra_data, coder: JSON

  SCOPES = {
    # incoming-webhook => "identify,incoming-webhook,chat:write:bot"
    slack: "incoming-webhook"
  }

  def self.oauth2_client(provider)
    config = provider_configuration(provider)

    OAuth2::Client.new(
      config[:client_id],
      config[:client_secret],
      site: config[:url],
      token_url: config[:token_url]
    )
  end

  def self.create_from_oauth_token(provider:, code:, application:, user:)
    token = oauth2_client(provider).auth_code.get_token(code)

    application.create_oauth_token!(
      organization: application.organization,
      application: application,
      user: user,
      token: token.token,
      scope: token.params["scope"],
      extra_data: provider_extra_data(provider, token.params)
    )
  end

  def self.provider_configuration(provider)
    case provider
    when "slack"
      {
        client_id: ENV["SHIPYRD_SLACK_CLIENT_ID"],
        client_secret: ENV["SHIPYRD_SLACK_SECRET"],
        url: "https://slack.com",
        token_url: "/api/oauth.access"
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
