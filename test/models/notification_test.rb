require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @application = create(:application)
    @webhook = @application.webhooks.create!(user: create(:user), url: "http://example.com")
    @channel = @webhook.channel
    @destination = create(:destination, application: @application)
    @user = create(:user)
    @notification = create(:notification, channel: @channel, destination: @destination, details: {user_id: @user.id})
  end

  it "notifies the channel owner" do
    @channel.owner.expects(:notify).once.with(
      @notification.event,
      @notification.details.merge(
        destination_name: @destination.name,
        destination_id: @destination.id,
        application_name: @destination.application.name,
        application_id: @destination.application.id,
        user_name: @user.display_name
      )
    )

    @notification.notify

    assert @notification.notified_at

    # Ensuring that the notification is only sent once
    @notification.notify
  end
end
