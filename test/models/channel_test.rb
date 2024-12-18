require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
    @user = create(:user)
    @oauth_token = create(:oauth_token, user: @user, application: @application)
    @channel = create(:channel, owner: @oauth_token, application: @application)
  end

  test "should normalize events" do
    @channel.events = ["deploy", "", "lock"]
    @channel.save
    assert_equal ["deploy", "lock"], @channel.events
  end

  test "should return available channels" do
    OauthToken.stub :configured_providers, ["github", "slack"] do
      assert_equal [:webhook, :github, :slack], Channel.available_channels
    end
  end

  test "should return display name" do
    @channel.channel_type = "github"
    assert_equal "Github", @channel.display_name
  end
end
