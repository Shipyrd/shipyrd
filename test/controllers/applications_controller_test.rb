require "test_helper"
require "helpers/basic_auth_helpers"

class ApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
  end

  describe "anonymous" do
    it "denies access" do
      get applications_url
      assert_response :unauthorized
    end
  end

  describe "authenticated" do
    before do
      @user = create(:user)
      sign_in(@user.email, @user.password)
    end

    test "should get index" do
      get applications_url

      assert_response :success
    end

    test "should show application" do
      get application_url(@application)

      assert_response :success
    end

    test "should get edit" do
      get edit_application_url(@application)

      assert_response :success
    end

    test "should update application" do
      patch application_url(@application), params: {application: {name: @application.name, repository_url: @application.repository_url}}

      assert_redirected_to edit_application_url(@application)
    end

    test "should destroy application" do
      assert_difference("Application.count", -1) do
        delete application_url(@application)
      end

      assert_redirected_to applications_url
    end
  end
end
