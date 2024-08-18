require "test_helper"
require "helpers/basic_auth_helpers"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application_with_repository_url)
    Connection.any_instance.stubs(:connects_successfully)
  end

  describe "authenticated" do
    before do
      @api_key = ApiKey.create!
      @auth_headers = auth_headers(@api_key.token)
    end

    test "should get index" do
      get application_connections_url(@application), headers: @auth_headers
      assert_response :success
    end

    test "should get new" do
      get new_application_connection_url(@application, provider: :github), headers: @auth_headers
      assert_response :success
    end

    test "should create" do
      post application_connections_url(@application), params: {connection: {provider: "github", key: "123456"}}, headers: @auth_headers
      assert_redirected_to edit_application_url(@application)
    end

    test "should only create with valid provider" do
      post application_connections_url(@application), params: {connection: {provider: "bezos", key: "123456"}}, headers: @auth_headers
      assert_redirected_to edit_application_url(@application)
    end

    test "should destroy" do
      @connection = @application.connections.create!(provider: :github)

      assert_difference("Connection.count", -1) do
        delete application_connection_url(@application, @connection), headers: @auth_headers
      end

      assert_redirected_to edit_application_url(@application)
    end
  end
end
