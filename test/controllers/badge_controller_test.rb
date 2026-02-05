require "test_helper"

class BadgeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @destination = create(:destination, application: @application, name: "production")
  end

  test "returns 404 when badge key does not exist" do
    get "/applications/nonexistent-badge-key/destinations/production/badge/deploy", as: :json

    assert_response :not_found
  end

  test "returns 404 when destination does not exist" do
    get "/applications/#{@application.badge_key}/destinations/nonexistent-destination/badge/deploy", as: :json

    assert_response :not_found
  end

  test "deploy badge" do
    get badge_deploy_url, as: :json

    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "🚀 production", data["label"]
    assert_equal "red", data["color"]
    assert_equal "never", data["message"]

    create(:deploy,
      application: @application,
      destination: @destination.name,
      status: "post-deploy",
      recorded_at: 1.hour.ago)

    get badge_deploy_url, as: :json

    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "🚀 production", data["label"]
    assert_equal "about 1 hour ago", data["message"]
  end

  test "lock badge" do
    get badge_lock_url, as: :json

    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "🔓 production", data["label"]
    assert_equal "green", data["color"]
    assert_equal "unlocked", data["message"]

    user = create(:user)
    @destination.lock!(user)

    get badge_lock_url, as: :json

    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "🔒 production", data["label"]
    assert_equal "yellow", data["color"]
    assert_equal user.display_name, data["message"]
  end

  private

  def badge_deploy_url
    "/applications/#{@application.badge_key}/destinations/#{@destination.name || "default"}/badge/deploy.json"
  end

  def badge_lock_url
    "/applications/#{@application.badge_key}/destinations/#{@destination.name || "default"}/badge/lock.json"
  end
end
