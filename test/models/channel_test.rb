require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
    @user = create(:user)
    @oauth_token = create(:oauth_token, user: @user, organization: @application.organization, application: @application)
    @channel = create(:channel, owner: @application, oauth_token: @oauth_token, organization: @application.organization)
  end

  test "should normalize events" do
    @channel.events = ["deploy", "", "lock"]
    @channel.save
    assert_equal ["deploy", "lock"], @channel.events
  end

  test "should return available channels" do
    OauthToken.stub :configured_providers, ["github", "slack"] do
      assert_equal [:github, :slack], Channel.available_channels
    end
  end

  test "should return display name" do
    @channel.channel_type = "github"
    assert_equal "Github", @channel.display_name
  end
end
