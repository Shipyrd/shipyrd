require "test_helper"

class WebhookTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @application = create(:application)
    @webhook = build(:webhook, user: @user, application: @application)
  end

  test "should be invalid without a url" do
    @webhook.url = nil
    assert_not @webhook.valid?
    assert_includes @webhook.errors[:url], "can't be blank"
  end

  test "should be invalid with a local url" do
    @webhook.url = "http://localhost:3000"
    assert_not @webhook.valid?
    assert_includes @webhook.errors[:url], "is not a valid URL"
  end

  test "should create a channel after creation" do
    assert_difference "Channel.count", 1 do
      @webhook.url = "https://example.com"
      @webhook.save!
    end

    assert_equal @webhook, @webhook.channel.owner
    assert_equal @application, @webhook.channel.application
    assert_equal "webhook", @webhook.channel.channel_type
  end

  test "notifies the url via post" do
    @webhook.url = "https://example.com"
    @destination = create(:destination, name: "production", application: @application)

    stub_request = stub_request(:post, @webhook.url)
      .with(body: {event: :test, application: @application.name, destination: @destination.name, test: "test"}.to_json)
      .to_return(status: 200)

    @webhook.notify(:test, destination: @destination, details: {test: "test"})

    assert_requested(stub_request)
  end
end
