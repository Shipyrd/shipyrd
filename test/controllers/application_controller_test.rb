require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "redirects to sign in when not authenticated" do
    get root_url
    assert_redirected_to new_session_url
  end

  test "renders when signed in" do
    @user = create(:user)

    post session_url, params: {email: @user.email, password: @user.password}

    assert_redirected_to root_path
  end

  test "community_edition?" do
    ENV["COMMUNITY_EDITION"] = "1"
    assert ApplicationController.new.community_edition?

    ENV["COMMUNITY_EDITION"] = "0"
    refute ApplicationController.new.community_edition?

    ENV.delete("COMMUNITY_EDITION")
    assert ApplicationController.new.community_edition?
  end

  describe "API authentication" do
    setup do
      @user = create(:user)
      @organization = create(:organization)
      @organization.memberships.create(user: @user)
      @application = create(:application, organization: @organization)
      @destination = create(:destination, application: @application, name: "production")
    end

    test "should authenticate with valid user token for JSON requests" do
      patch lock_application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
    end

    test "should require authorization token for JSON requests" do
      patch lock_application_destination_path(@application, @destination.name),
        headers: {Accept: "application/json"}

      assert_response :unauthorized
      response_data = JSON.parse(response.body)
      assert_equal "Authorization token required", response_data["error"]
    end

    test "should reject invalid token for JSON requests" do
      patch lock_application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer invalid_token", Accept: "application/json"}

      assert_response :unauthorized
      response_data = JSON.parse(response.body)
      assert_equal "Invalid token", response_data["error"]
    end

    test "should not allow access to applications from other organizations" do
      # Create another user with their own organization and application
      other_user = create(:user)
      other_organization = create(:organization)
      other_organization.memberships.create(user: other_user)
      other_application = create(:application, organization: other_organization)
      other_destination = create(:destination, application: other_application, name: "production")

      # Try to access the other user's application with our user's token
      patch lock_application_destination_path(other_application, other_destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :not_found
      response_data = JSON.parse(response.body)
      assert_equal "Not found", response_data["error"]
    end

    test "should authenticate with valid application token for JSON requests" do
      application = create(:application)

      post deploys_url,
        params: {
          format: :json,
          deploy: {
            command: "deploy",
            recorded_at: Time.zone.now,
            performer: "test",
            version: "123456",
            service_version: "test@123456",
            status: "pre-build"
          }
        },
        headers: {Authorization: "Bearer #{application.token}", Accept: "application/json"}

      assert_response :created
    end

    test "should reject invalid application token for JSON requests" do
      post deploys_url,
        params: {
          format: :json,
          deploy: {
            command: "deploy",
            recorded_at: Time.zone.now,
            performer: "test",
            version: "123456",
            service_version: "test@123456",
            status: "pre-build"
          }
        },
        headers: {Authorization: "Bearer invalid_app_token", Accept: "application/json"}

      assert_response :unauthorized
      response_data = JSON.parse(response.body)
      assert_equal "Invalid token", response_data["error"]
    end

    test "should reject user token for deploys controller" do
      user = create(:user)

      post deploys_url,
        params: {
          format: :json,
          deploy: {
            command: "deploy",
            recorded_at: Time.zone.now,
            performer: "test",
            version: "123456",
            service_version: "test@123456",
            status: "pre-build"
          }
        },
        headers: {Authorization: "Bearer #{user.token}", Accept: "application/json"}

      assert_response :unauthorized
      response_data = JSON.parse(response.body)
      assert_equal "Invalid token", response_data["error"]
    end
  end
end
