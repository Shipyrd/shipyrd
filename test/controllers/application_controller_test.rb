require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "prompt for http basic auth when no users yet" do
    get root_url

    assert_response :unauthorized
  end

  test "redirects to sign in after a user is created" do
    create(:user, role: :user)

    get root_url

    assert_redirected_to new_session_url
  end
end
