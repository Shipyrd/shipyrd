require "test_helper"
require "helpers/basic_auth_helpers"

class OauthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = create(:application)
    @organization = @application.organization
  end

  describe "anonymous" do
    it "denies access" do
      get oauth_authorize_url(:slack)

      assert_redirected_to new_session_url
    end
  end

  describe "authenticated" do
    setup do
      @admin = create(:user)
      @organization.memberships.create(user: @admin, role: :admin)
      sign_in(@admin.email, @admin.password)
    end

    test "should start authorize" do
      get oauth_authorize_url(:slack, application_id: @application.id)

      assert_redirected_to %r{https://slack.com/oauth/authorize}
    end

    test "callback fails with invalid state" do
      assert_raises(RuntimeError) do
        get oauth_callback_url(:slack, code: "123", state: "123")
      end
    end

    test "should handle callback" do
      OauthController.any_instance.stubs(:oauth_session_state).returns("123")
      OauthController.any_instance.stubs(:current_application).returns(@application)
      OauthToken.stubs(:create_from_oauth_token).returns(OauthToken.new(application: @application))

      get oauth_callback_url(:slack, code: "123", state: "123")

      assert_redirected_to edit_application_url(@application)
    end
  end
end
