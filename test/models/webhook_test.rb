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

    Resolv.stubs(:getaddresses).returns(["93.184.216.34"])
    @webhook.notify(:lock, {test: "true"})

    assert_requested(stub_request)
  end

  test "fires on deploy event with post-deploy status" do
    @webhook.url = "https://example.com"
    stub = stub_request(:post, @webhook.url).to_return(status: 200)
    Resolv.stubs(:getaddresses).returns(["93.184.216.34"])

    @webhook.notify(:deploy, {status: "post-deploy"})

    assert_requested(stub)
  end

  test "fires on deploy event with failed status" do
    @webhook.url = "https://example.com"
    stub = stub_request(:post, @webhook.url).to_return(status: 200)
    Resolv.stubs(:getaddresses).returns(["93.184.216.34"])

    @webhook.notify(:deploy, {status: "failed"})

    assert_requested(stub)
  end

  test "skips deploy event on pre-deploy status" do
    @webhook.url = "https://example.com"
    stub = stub_request(:post, @webhook.url).to_return(status: 200)
    Resolv.stubs(:getaddresses).returns(["93.184.216.34"])

    @webhook.notify(:deploy, {status: "pre-deploy"})

    assert_not_requested(stub)
  end

  test "refuses to notify a private-IP host without raising" do
    @webhook.url = "https://internal.example.com"
    @webhook.save!

    stub = stub_request(:post, @webhook.url)
    Resolv.stubs(:getaddresses).returns(["10.0.0.5"])

    assert_nothing_raised { @webhook.notify(:lock, {test: "true"}) }
    assert_not_requested(stub)
  end
end
