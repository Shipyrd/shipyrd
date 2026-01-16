require "test_helper"

class OauthTokensTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
    @user = create(:user)
  end

  test "user_token? returns true when associated with a user and false otherwise" do
    assert OauthToken.new(user: @user, provider: :slack).user_token?
    refute OauthToken.new(application: @application, provider: :slack).user_token?
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

  describe "create user from oauth" do
    setup do
      @organization = create(:organization)
      token = OAuth2::AccessToken.from_hash(
        OauthToken.oauth2_client("github"),
        {
          access_token: "github-token"
        }
      )

      OAuth2::Client.any_instance.stubs(:auth_code).returns(stub(get_token: token))

      @user_stub = stub(
        login: "username",
        avatar_url: "https://github.com/avatar.png",
        name: "user",
        email: "test@example.com"
      )

      Octokit::Client.stubs(:new).returns(
        stub(
          user: @user_stub,
          emails: [{
            email: "additional@example.com",
            verified: true
          }]
        )
      )
    end

    test "creates a user from oauth when user doesn't exist" do
      token = OauthToken.create_from_oauth_token(
        provider: "github",
        code: "123",
        redirect_uri: nil,
        organization: @organization,
        role: :admin
      )

      user = token.user
      assert_equal "https://github.com/username", user.username
      assert_equal @user_stub.name, user.name
      assert_equal "#{@user_stub.avatar_url}&s=100", user.avatar_url
      assert_equal "additional@example.com", user.email_addresses.last.email
      membership = @organization.memberships.find_by!(user: user)

      assert membership.admin?
    end

    test "create a new organization if not invited" do
      token = OauthToken.create_from_oauth_token(
        provider: "github",
        code: "123",
        redirect_uri: nil,
        organization: nil,
        role: nil
      )

      user = token.user
      assert_equal "https://github.com/username", user.username
      assert_equal @user_stub.name, user.name
      assert_equal "#{@user_stub.avatar_url}&s=100", user.avatar_url
      assert_equal "additional@example.com", user.email_addresses.last.email
      organization = user.memberships.find_by(role: :admin).organization

      assert_equal organization.name, user.name
    end
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
