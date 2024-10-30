require "test_helper"
require "helpers/basic_auth_helpers"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @destination = create(:destination, application: @application)
  end

  describe "anonymous" do
    it "denies access" do
      get application_destination_path(@application, @destination)

      assert_response :unauthorized
    end
  end

  describe "authenticated" do
    setup do
      @user = create(:user)
      sign_in(@user.email, @user.password)
    end

    test "should get edit" do
      get edit_application_destination_path(@application, @destination)

      assert_response :success
    end

    test "should get show" do
      get application_destination_path(@application, @destination)

      assert_response :success
    end

    test "should update destination" do
      patch application_destination_path(@application, @destination), params: {destination: {branch: @destination.branch, name: @destination.name, url: @destination.url}}

      assert_redirected_to application_destination_path(@application, @destination)
    end
  end
end
