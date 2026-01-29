require "test_helper"
require "helpers/basic_auth_helpers"

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
    end

    test "should authenticate with valid user token for JSON requests" do
      get applications_url, headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
    end

    test "should require authorization token for JSON requests" do
      get applications_url, headers: {Accept: "application/json"}

      assert_response :unauthorized
      response_data = JSON.parse(response.body)
      assert_equal "Authorization token required", response_data["error"]
    end

    test "should reject invalid token for JSON requests" do
      get applications_url, headers: {Authorization: "Bearer invalid_token", Accept: "application/json"}

      assert_response :unauthorized
      response_data = JSON.parse(response.body)
      assert_equal "Invalid token", response_data["error"]
    end

    test "should authenticate with valid application token for deploys controller" do
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

    test "should reject user token for deploys controller" do
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
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

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

      # Try to access the other user's application with our user's token
      get application_url(other_application), headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :not_found
      response_data = JSON.parse(response.body)
      assert_equal "Not found", response_data["error"]
    end
  end

  describe "current_organization" do
    setup do
      @user = create(:user)
      @organization1 = create(:organization, name: "Organization 1")
      @organization2 = create(:organization, name: "Organization 2")
      @organization1.memberships.create(user: @user)
      @organization2.memberships.create(user: @user)
    end

    test "defaults to first organization when no session organization_id" do
      sign_in(@user.email, @user.password)

      get root_url

      assert_response :success
      assert_equal @organization1.id, session[:organization_id]
    end

    test "uses session organization_id when present" do
      sign_in(@user.email, @user.password)

      get root_url
      follow_redirect! if response.redirect?

      post switch_organization_path(@organization2)
      follow_redirect! if response.redirect?

      get root_url

      assert_response :success
      assert_equal @organization2.id, session[:organization_id]
    end

    test "falls back to first organization when session organization_id is invalid" do
      sign_in(@user.email, @user.password)

      get root_url
      follow_redirect! if response.redirect?
      assert_equal @organization1.id, session[:organization_id]

      @organization1.memberships.find_by(user: @user).destroy

      get root_url

      assert_response :success
      assert_equal @organization2.id, session[:organization_id]
    end

    test "returns nil when user has no organizations" do
      user_without_orgs = create(:user)
      sign_in(user_without_orgs.email, user_without_orgs.password)

      get root_url

      assert_nil session[:organization_id]
    end

    test "memoizes current_organization within a request" do
      sign_in(@user.email, @user.password)

      get root_url

      assert_response :success
      first_org_id = session[:organization_id]

      get root_url

      assert_response :success
      assert_equal first_org_id, session[:organization_id]
    end
  end
end
