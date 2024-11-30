require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "redirects to sign in when not authenticated" do
    get root_url
    assert_redirected_to new_session_url
  end

  test "renders when signed in" do
    @user = create(:user)

    post session_url, params: {email: @user.email, password: @user.password}

    assert_redirected_to root_path
  end
end