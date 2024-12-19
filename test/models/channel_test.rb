require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  setup do
    @oauth_token = create(:oauth_token)
    @channel = @oauth_token.channel
  end

  test "should normalize events" do
    @channel.events = ["deploy", "", "lock"]
    @channel.save
    assert_equal ["deploy", "lock"], @channel.events
  end

  test "should return available channels" do
    OauthToken.stubs(:configured_providers).returns(["github", "slack"])

    assert_equal [:webhook, :github, :slack], Channel.available_channels
  end

  test "should return display name" do
    @channel.channel_type = "github"
    assert_equal "Github", @channel.display_name
  end
end
