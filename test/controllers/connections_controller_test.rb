require "test_helper"
require "helpers/basic_auth_helpers"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application_with_repository_url)
    @organization = @application.organization
    Connection.any_instance.stubs(:connects_successfully)
    Connection.any_instance.stubs(:import_deploy_recipes)
  end

  test "requires authentication" do
    get application_connections_url(@application)

    assert_redirected_to new_session_path
  end

  describe "authenticated" do
    before do
      @user = create(:user)
      @organization.memberships.create(user: @user)
      sign_in(@user.email, @user.password)
    end

    test "should get index" do
      get application_connections_url(@application)

      assert_response :success
    end

    test "should get new" do
      get new_application_connection_url(@application, provider: :github)

      assert_response :success
    end

    test "should create" do
      post application_connections_url(@application), params: {connection: {provider: "github", key: "123456"}}

      assert_redirected_to edit_application_url(@application)
    end

    test "should only create with valid provider" do
      post application_connections_url(@application), params: {connection: {provider: "bezos", key: "123456"}}

      assert_redirected_to edit_application_url(@application)
    end

    test "should destroy" do
      @connection = @application.connections.create!(provider: :github)

      assert_difference("Connection.count", -1) do
        delete application_connection_url(@application, @connection)
      end

      assert_redirected_to edit_application_url(@application)
    end
  end
end
