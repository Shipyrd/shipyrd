require "test_helper"

class OauthTokensTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
    @user = create(:user)
  end

  test "creates a channel" do
    token = OauthToken.create!(
      user: @user,
      application: @application,
      provider: :slack
    )

    channel = token.channel

    assert_equal @application, channel.application
    assert_equal token, channel.owner
    assert_equal "slack", channel.channel_type
    assert_equal Channel::EVENTS, channel.events
  end

  test "creates an oauth token" do
    token = OAuth2::AccessToken.from_hash(
      OauthToken.oauth2_client("slack"),
      {
        access_token: "slack-token",
        team_id: "T123456",
        team_name: "team-name",
        scope: "identify,incoming-webhook,chat:write:bot",
        incoming_webhook: {
          channel_id: "C123456",
          channel: "channel-name",
          configuration_url: "https://team.slack.com/services/slack-id",
          url: "https://hooks.slack.com/services/id/service-id/webhook-id"
        }
      }.deep_stringify_keys
    )

    OAuth2::Client.any_instance.stubs(:auth_code).returns(stub(get_token: token))

    authentication = OauthToken.create_from_oauth_token(
      provider: "slack",
      code: "123",
      application: @application,
      user: @user,
      redirect_uri: "https://example.com"
    )

    assert_equal @user, authentication.user
    assert_equal @application, authentication.application
    assert_equal "slack-token", authentication.token
    assert_equal authentication.extra_data, {
      "channel_id" => "C123456",
      "channel_name" => "channel-name",
      "url" => "https://hooks.slack.com/services/id/service-id/webhook-id",
      "configuration_url" => "https://team.slack.com/services/slack-id",
      "team_id" => "T123456",
      "team_name" => "team-name"
    }
  end

  test "notifies the slack channel" do
    token = create(:oauth_token, user: @user, application: @application, provider: :slack, extra_data: {channel_id: "C123456"})
    details = {test: "test"}

    notify = stub(notify: nil)
    notify.expects(:notify).with(:lock, details.merge(channel_id: token.extra_data["channel_id"]))
    Slack.expects(:new).with(token.token).returns(notify)

    token.notify(:lock, details)
  end
end
