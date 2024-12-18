require "test_helper"

class ChannelsHelperTest < ActionView::TestCase
  test "connect_channel_url returns correct URL for webhook provider" do
    application_id = 123
    expected_url = new_application_webhook_url(application_id)
    assert_equal expected_url, connect_channel_url(:webhook, application_id: application_id)
  end

  test "connect_channel_url returns correct URL for oauth provider" do
    application_id = 123
    provider = :slack
    expected_url = oauth_authorize_url(provider, application_id: application_id)
    assert_equal expected_url, connect_channel_url(provider, application_id: application_id)
  end

  test "channel_icon returns correct icon for webhook" do
    assert_equal "fa-solid fa-bolt", channel_icon("webhook")
  end

  test "channel_icon returns correct icon for other channel types" do
    assert_equal "fa-brands fa-slack", channel_icon("slack")
    assert_equal "fa-brands fa-github", channel_icon("github")
  end

  test "label_for_channel_event_type returns correct label for Application deploy" do
    assert_equal "Deploys - Send a notification when a deploy completes", label_for_channel_event_type("Application", :deploy)
  end

  test "label_for_channel_event_type returns correct label for Application lock" do
    assert_equal "Locks - Send a notification when a destination is locked/unlocked", label_for_channel_event_type("Application", :lock)
  end

  test "label_for_channel_event_type returns nil for unknown event types" do
    assert_nil label_for_channel_event_type("Application", :unknown)
    assert_nil label_for_channel_event_type("Unknown", :deploy)
  end
end
