require "test_helper"
require "helpers/basic_auth_helpers"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @api_key = ApiKey.create!
    @auth_headers = auth_headers(@api_key.token)
  end

  test "should get index" do
    get users_url
    assert_response :success, headers: @auth_headers
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: {user: {email: @user.email, name: @user.name, password: "secret", password_confirmation: "secret", username: @user.username}}
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    # TODO: if is current user
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    # TODO: if is current user
    patch user_url(@user), params: {user: {avatar_url: @user.avatar_url, email: @user.email, name: @user.name, password: "secret", password_confirmation: "secret", username: @user.username}}
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    # TODO: if has admin role
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
