require "test_helper"
require "helpers/basic_auth_helpers"

class RunnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @destination = create(:destination, application: @application)
  end

  describe "anonymous" do
    it "denies access" do
      get application_destination_runners_path(@application, @destination)
      assert_response :unauthorized
    end
  end

  describe "authenticated" do
    describe "user" do
      setup do
        @user = create(:user, password: "password")
        sign_in(@user.email, "password")
      end

      test "should not create runner" do
        post application_destination_runners_path(@application, @destination), params: {runner: {command: "lock status"}}

        assert_redirected_to root_url
      end
    end

    describe "admin" do
      setup do
        @user = create(:user, role: :admin, password: "password")
        sign_in(@user.email, "password")
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
