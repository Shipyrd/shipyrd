require "test_helper"

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
      @api_key = ApiKey.create
      @auth_headers = {Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("", @api_key.token)}
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
      patch application_url(@application), params: {application: {environment: @application.environment, name: @application.name, repository_url: @application.repository_url, url: @application.url}}, headers: @auth_headers
      assert_redirected_to application_url(@application)
    end

    test "should destroy application" do
      assert_difference("Application.count", -1) do
        delete application_url(@application), headers: @auth_headers
      end

      assert_redirected_to applications_url
    end
  end
end
