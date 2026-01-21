require "test_helper"

class IncomingWebhookTest < ActiveSupport::TestCase
  test "url" do
    incoming_webhook = build(:incoming_webhook, token: "token")

    assert_equal "https://hooks.shipyrd.test/incoming/honeybadger/token", incoming_webhook.url
  end
end
