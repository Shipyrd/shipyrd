require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "prompt for http basic auth when no users yet" do
    get root_url

    assert_response :unauthorized
  end

  test "prompts for auth with just a deploy created user" do
    create(:user, role: :user, password: nil)

    get root_url

    assert_response :unauthorized
  end

  test "redirects to sign in after a password-based user is created" do
    create(:user, role: :user, password: "secretsecret")

    get root_url

    assert_redirected_to new_session_url
  end
end
