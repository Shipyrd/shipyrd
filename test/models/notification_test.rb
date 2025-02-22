require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @webhook = create(:webhook)
    @channel = @webhook.channel
    @user = create(:user)
    @notification = create(
      :notification,
      channel: @channel,
      details: {user_id: @user.id}
    )
    @destination = @notification.destination
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
      ).symbolize_keys
    )

    @notification.notify

    assert @notification.notified_at

    # Ensuring that the notification is only sent once
    @notification.notify
  end

  it "figures out a user name for the notification" do
    assert_equal @user.display_name, @notification.user_name

    @notification.update!(details: {performer: @user.username, user_id: nil})
    User.stubs(:lookup_performer).returns("username")
    assert_equal "username", @notification.user_name
  end
end
