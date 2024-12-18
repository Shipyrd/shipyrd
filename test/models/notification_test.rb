require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
    @webhook = @application.webhooks.create!(user: create(:user), url: "http://example.com")
    @channel = @webhook.channel
    @destination = create(:destination, application: @application)
    @notification = create(:notification, channel: @channel, destination: @destination)
  end

  it "notifies the channel owner" do
    @channel.owner.expects(:notify).once.with(
      @notification.event,
      destination: @destination,
      details: @notification.details
    )

    @notification.notify

    assert @notification.notified_at

    # Ensuring that the notification is only sent once
    @notification.notify
  end
end
