require "test_helper"
require "helpers/basic_auth_helpers"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @destination = create(:destination, name: "production")
    @application = @destination.application
    @organization = @application.organization
  end

  describe "anonymous" do
    it "denies access" do
      get application_destination_path(@application, @destination)

      assert_redirected_to new_session_path
    end
  end

  describe "authenticated" do
    setup do
      @user = create(:user)
      @organization.memberships.create(user: @user)
      sign_in(@user.email, @user.password)
    end

    test "get edit" do
      get edit_application_destination_path(@application, @destination)

      assert_response :success
    end

    test "get show" do
      get application_destination_path(@application, @destination)

      assert_response :success
    end

    test "update destination" do
      patch application_destination_path(@application, @destination), params: {destination: {branch: @destination.branch, name: @destination.name, url: @destination.url}}

      assert_redirected_to application_destination_path(@application, @destination)
    end

    test "lock" do
      patch lock_application_destination_path(@application, @destination)

      assert @destination.reload.locked?
      assert_redirected_to root_path
    end

    test "unlock" do
      @destination.lock!(@user)

      delete unlock_application_destination_path(@application, @destination)

      assert_not @destination.reload.locked?
      assert_redirected_to root_path
    end
  end

  describe "API functionality" do
    setup do
      @user = create(:user)
      @organization.memberships.create(user: @user)
    end

    test "should lock destination with destination name via API" do
      patch lock_application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
      response_data = JSON.parse(response.body)
      assert_equal @destination.name, response_data["name"]
      assert_not_nil response_data["locked_at"]
      assert_equal @user.display_name, response_data["locked_by"]

      @destination.reload
      assert @destination.locked?
      assert_equal @user, @destination.locker
    end

    test "should unlock destination with destination name via API" do
      @destination.lock!(@user)

      delete unlock_application_destination_path(@application, @destination.name),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :ok
      response_data = JSON.parse(response.body)
      assert_equal @destination.name, response_data["name"]
      assert_nil response_data["locked_at"]
      assert_nil response_data["locked_by"]

      @destination.reload
      assert_not @destination.locked?
    end

    test "should return 404 for non-existent destination name" do
      patch lock_application_destination_path(@application, "nonexistent"),
        headers: {Authorization: "Bearer #{@user.token}", Accept: "application/json"}

      assert_response :not_found
      response_data = JSON.parse(response.body)
      assert_equal "Not found", response_data["error"]
    end
  end
end
