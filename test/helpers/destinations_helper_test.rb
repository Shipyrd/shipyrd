require "test_helper"

class DestinationsHelperTest < ActionView::TestCase
  setup do
    @application = create(:application)
    @application.update_column(:badge_key, "badge-key")
    @destination = create(:destination, application: @application, name: "production")
  end

  test "destination_badge deploy image" do
    assert_equal "https://img.shields.io/endpoint?url=https://badge.test/applications/#{@application.badge_key}/destinations/#{@destination.name}/badge/deploy.json",
      destination_badge(@destination, :deploy)
  end

  test "destination_badge deploy markdown" do
    assert_equal "![#{@destination.name}](https://img.shields.io/endpoint?url=https://badge.test/applications/#{@application.badge_key}/destinations/#{@destination.name}/badge/deploy.json)",
      destination_badge(@destination, :deploy, :markdown)
  end

  test "destination_badge lock image" do
    assert_equal "https://img.shields.io/endpoint?url=https://badge.test/applications/#{@application.badge_key}/destinations/#{@destination.name}/badge/lock.json",
      destination_badge(@destination, :lock)
  end

  test "destination_badge lock markdown" do
    assert_equal "![#{@destination.name}](https://img.shields.io/endpoint?url=https://badge.test/applications/#{@application.badge_key}/destinations/#{@destination.name}/badge/lock.json)",
      destination_badge(@destination, :lock, :markdown)
  end

  test "destination_badge uses default when destination name is nil" do
    @destination.update!(name: nil)

    assert_equal "https://img.shields.io/endpoint?url=https://badge.test/applications/#{@application.badge_key}/destinations/#{@destination.name || "default"}/badge/deploy.json",
      destination_badge(@destination, :deploy)
  end
end
