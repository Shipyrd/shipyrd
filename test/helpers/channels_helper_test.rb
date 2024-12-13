require 'test_helper'

class ChannelsHelperTest < ActionView::TestCase
  test "channel_icon returns correct icon for webhook" do
    assert_equal "fa-solid fa-bolt", channel_icon("webhook")
  end

  test "channel_icon returns correct icon for other channel types" do
    assert_equal "fa-brands fa-slack", channel_icon("slack")
    assert_equal "fa-brands fa-twitter", channel_icon("twitter")
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
