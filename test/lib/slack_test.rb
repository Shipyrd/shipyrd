require "test_helper"

class SlackTest < ActiveSupport::TestCase
  setup do
    @slack = Slack.new("token")
  end

  test "lock notification" do
    @slack.expects(:send_message).with(
      channel_id: "C123456",
      message: ":lock: user_name locked application_name"
    )

    @slack.notify(:lock, {user_name: "user_name", application_name: "application_name", channel_id: "C123456"})
  end

  test "unlock notification" do
    @slack.expects(:send_message).with(
      channel_id: "C123456",
      message: ":unlock: user_name unlocked application_name"
    )

    @slack.notify(:unlock, {user_name: "user_name", application_name: "application_name", channel_id: "C123456"})
  end
end
