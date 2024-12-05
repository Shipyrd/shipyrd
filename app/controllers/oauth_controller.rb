class OauthController < ApplicationController
  def authorize
    client ||= OAuth2::Client.new(
      ENV["SHIPYRD_SLACK_CLIENT_ID"],
      ENV["SHIPYRD_SLACK_SECRET"],
      site: "https://slack.com",
      token_url: "/api/oauth.access"
    )

    # TODO: Store state param, pass that with setup and verify on
    # callback
    params = {
      scope: "incoming-webhook",
      # bot_scope: 'chat:write,channels:join,chat:write.public',
      state: "this-is-state", # Store this on the org
      redirect_uri: oauth_callback_url(host: ENV["SHIPYRD_HOST"], protocol: :https)
    }

    redirect_to client.auth_code.authorize_url(params), allow_other_host: true
  end

  def callback
    client ||= OAuth2::Client.new(
      ENV["SHIPYRD_SLACK_CLIENT_ID"],
      ENV["SHIPYRD_SLACK_SECRET"],
      site: "https://slack.com",
      token_url: "/api/oauth.access"
    )

    client.auth_code.get_token(
      params[:code],
      redirect_uri: oauth_callback_url(host: ENV["SHIPYRD_HOST"], protocol: :https)
    )

    redirect_to root_url
  end
end
