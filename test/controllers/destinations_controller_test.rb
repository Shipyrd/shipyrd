require "test_helper"
require "helpers/basic_auth_helpers"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization
    @destination = create(:destination, application: @application)
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

      patch unlock_application_destination_path(@application, @destination)

      assert_not @destination.reload.locked?
      assert_redirected_to root_path
    end
  end
end
