require "test_helper"
require "helpers/basic_auth_helpers"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url
    assert_response :success
  end

  describe "with user" do
    setup do
      @user = create(:user, role: :user, password: "password")
    end

    test "with invalid credentials" do
      post session_url, params: {email: @user.email, password: "nah"}

      assert_redirected_to new_session_url
    end

    test "with valid credentials" do
      post session_url, params: {email: @user.email, password: "password"}

      assert_redirected_to root_path
    end

    test "sign out" do
      post session_url, params: {email: @user.email, password: "password"}
      delete session_url

      assert_redirected_to new_session_url
    end
  end
end
