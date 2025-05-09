require "test_helper"
require "helpers/basic_auth_helpers"

class RunnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization
    @destination = create(:destination, application: @application)
  end

  describe "anonymous" do
    it "denies access" do
      get application_destination_runners_path(@application, @destination)
      assert_redirected_to new_session_path
    end
  end

  describe "authenticated" do
    describe "user" do
      setup do
        @user = create(:user)
        @organization.memberships.create(user: @user)
        sign_in(@user.email, @user.password)
      end

      test "should not create runner" do
        post application_destination_runners_path(@application, @destination), params: {runner: {command: "lock status"}}

        assert_redirected_to root_url
      end
    end

    describe "admin" do
      setup do
        @user = create(:user)
        @organization.memberships.create(user: @user, role: :admin)
        sign_in(@user.email, @user.password)
      end

      test "should get index" do
        get application_destination_runners_path(@application, @destination)

        assert_response :success
      end

      test "should get new" do
        get new_application_destination_runner_path(@application, @destination)

        assert_response :success
      end

      test "should get show" do
        @runner = create(:runner, destination: @destination)

        get application_destination_runner_path(@application, @destination, @runner)

        assert_response :success
      end

      test "should create runner" do
        post application_destination_runners_path(@application, @destination), params: {runner: {command: "lock status"}}

        @runner = @destination.runners.last

        assert_redirected_to application_destination_runner_path(@application, @destination, @runner)
      end
    end
  end
end
