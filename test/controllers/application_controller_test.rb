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

  test "community_edition?" do
    ENV["COMMUNITY_EDITION"] = "1"
    assert ApplicationController.new.community_edition?

    ENV["COMMUNITY_EDITION"] = "0"
    refute ApplicationController.new.community_edition?

    ENV.delete("COMMUNITY_EDITION")
    assert ApplicationController.new.community_edition?
  end

  test "runners_enabled?" do
    ENV["RUNNERS_ENABLED"] = "1"
    assert ApplicationController.new.runners_enabled?

    ENV["RUNNERS_ENABLED"] = "0"
    refute ApplicationController.new.runners_enabled?

    ENV.delete("RUNNERS_ENABLED")
    refute ApplicationController.new.runners_enabled?
  end
end
