require "test_helper"

class UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  test "shows unsubscribe confirmation page with valid token" do
    user = create(:user)
    token = user.generate_token_for(:unsubscribe)

    get unsubscribe_url(token)

    assert_response :success
    assert user.reload.weekly_deploy_summary?
  end

  test "unsubscribes user on update with valid token" do
    user = create(:user)
    assert user.weekly_deploy_summary?

    token = user.generate_token_for(:unsubscribe)
    patch unsubscribe_url(token)

    assert_redirected_to unsubscribe_path(token)
    refute user.reload.weekly_deploy_summary?
  end

  test "does not log user in" do
    user = create(:user)
    token = user.generate_token_for(:unsubscribe)

    patch unsubscribe_url(token)

    assert_nil session[:user_id]
  end

  test "redirects with invalid token on show" do
    get unsubscribe_url("invalid-token")

    assert_redirected_to root_path
  end

  test "redirects with invalid token on update" do
    patch unsubscribe_url("invalid-token")

    assert_redirected_to root_path
  end
end
