require "test_helper"
require "helpers/basic_auth_helpers"

class SystemAdminControllerTest < ActionDispatch::IntegrationTest
  test "redirects to sign in when not system admin" do
    get mission_control_jobs_path
    assert_redirected_to "/session/new"
  end
end
