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
      @api_key = ApiKey.create!
      @auth_headers = auth_headers(@api_key.token)
    end

    test "should get index" do
      get applications_url, headers: @auth_headers
      assert_response :success
    end

    test "should get new" do
      get new_application_url, headers: @auth_headers
      assert_response :success
    end

    test "should show application" do
      get application_url(@application), headers: @auth_headers
      assert_response :success
    end

    test "should get edit" do
      get edit_application_url(@application), headers: @auth_headers
      assert_response :success
    end

    test "should update application" do
      patch application_url(@application), params: {application: {name: @application.name, repository_url: @application.repository_url}}, headers: @auth_headers
      assert_redirected_to applications_url
    end

    test "should destroy application" do
      assert_difference("Application.count", -1) do
        delete application_url(@application), headers: @auth_headers
      end

      assert_redirected_to applications_url
    end
  end
end
