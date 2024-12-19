require "test_helper"

class WebhookTest < ActiveSupport::TestCase
  setup do
    @webhook = build(:webhook)
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
    assert_equal @webhook.application, @webhook.channel.application
    assert_equal "webhook", @webhook.channel.channel_type
  end

  test "notifies the url via post" do
    @webhook.url = "https://example.com"
    @destination = create(:destination, application: @webhook.application)

    stub_request = stub_request(:post, @webhook.url)
      .with(body: {
        event: :lock,
        test: "true"
      }.to_json)
      .to_return(status: 200)

    @webhook.notify(:lock, {test: "true"})

    assert_requested(stub_request)
  end
end
