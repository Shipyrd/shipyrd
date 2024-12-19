require "test_helper"

class SlackTest < ActiveSupport::TestCase
  setup do
    @slack = Slack.new("token")
  end

  test "lock notification" do
    @slack.expects(:send_message).with(
      channel_id: "C123456",
      message: ":red_circle: user_name locked *application_name*"
    )

    @slack.notify(:lock, {user_name: "user_name", application_name: "application_name", channel_id: "C123456"})
  end

  test "unlock notification" do
    @slack.expects(:send_message).with(
      channel_id: "C123456",
      message: ":large_green_circle: user_name unlocked *application_name*"
    )

    @slack.notify(:unlock, {user_name: "user_name", application_name: "application_name", channel_id: "C123456"})
  end

  test "deploy notification" do
    compare_url = "https://example.com"

    @slack.expects(:send_message).with(
      channel_id: "C123456",
      message: ":rocket: user_name deployed *application_name* <#{compare_url}|Compare>"
    )

    @slack.notify(:deploy, {user_name: "user_name", application_name: "application_name", channel_id: "C123456", compare_url: compare_url})
  end
end
