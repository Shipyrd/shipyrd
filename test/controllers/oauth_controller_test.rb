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

  describe "oauth with github" do
    let(:invite_link) { create(:invite_link, organization: @organization) }
    it "redirects to github.com/login/oauth" do
      get oauth_authorize_url(:github)

      assert_redirected_to %r{https://github.com/login/oauth/authorize}
    end

    it "handles the callback and loads the user" do
      oauth_token = build(:oauth_token, user: build(:user), application: nil)
      OauthToken.stubs(:create_from_oauth_token).returns(oauth_token)
      OauthController.any_instance.stubs(:oauth_session_state).returns("456")

      get new_user_url(code: invite_link.code)
      get oauth_callback_url(:github, code: "123", state: "456")

      assert_redirected_to root_path
    end

    it "supports invite links" do
      oauth_token = build(:oauth_token, user: build(:user), application: nil)
      OauthController.any_instance.stubs(:redirect_uri).returns("https://example.com")
      OauthToken.expects(:create_from_oauth_token).with(
        provider: "github",
        code: "123",
        application: nil,
        user: nil,
        organization: invite_link.organization,
        role: invite_link.role,
        redirect_uri: "https://example.com"
      ).returns(oauth_token)

      OauthController.any_instance.stubs(:oauth_session_state).returns("456")

      get new_user_url(code: invite_link.code)

      get oauth_callback_url(:github, code: "123", state: "456")

      assert_redirected_to root_path
    end
  end

  describe "authenticated" do
    setup do
      @admin = create(:user)
      @organization.memberships.create(user: @admin, role: :admin)
      @invite_link = create(:invite_link, organization: @organization)
      sign_in(@admin.email, @admin.password)
    end

    test "should start authorize" do
      get oauth_authorize_url(:slack, application_id: @application.id)

      assert_redirected_to %r{https://slack.com/oauth/authorize}
    end

    test "callback fails with invalid state" do
      get new_user_url(code: @invite_link.code)

      assert_raises(RuntimeError) do
        get oauth_callback_url(:slack, code: "123", state: "123")
      end
    end

    test "should handle callback" do
      OauthController.any_instance.stubs(:oauth_session_state).returns("123")
      OauthController.any_instance.stubs(:current_application).returns(@application)
      OauthToken.stubs(:create_from_oauth_token).returns(OauthToken.new(application: @application))

      get new_user_url(code: @invite_link.code)
      get oauth_authorize_url(:slack, application_id: @application.id)
      get oauth_callback_url(:slack, code: "123", state: "123")

      assert_redirected_to edit_application_url(@application)
    end
  end

  describe "slack_bot provider" do
    setup do
      @admin = create(:user)
      @organization.memberships.create(user: @admin, role: :admin)
      sign_in(@admin.email, @admin.password)
    end

    test "authorize redirects non-admins away" do
      non_admin = create(:user)
      @organization.memberships.create(user: non_admin, role: :user)
      delete session_url
      sign_in(non_admin.email, non_admin.password)

      get oauth_authorize_url(:slack_bot)

      assert_redirected_to root_path
    end

    test "callback persists slack workspace fields on success" do
      OauthController.any_instance.stubs(:oauth_session_state).returns("state-123")
      token = stub(
        token: "xoxb-bot-token",
        params: {"team" => {"id" => "T9999", "name" => "Acme Workspace"}}
      )
      client = stub
      auth_code = stub
      client.stubs(:auth_code).returns(auth_code)
      auth_code.stubs(:get_token).returns(token)
      OauthToken.stubs(:oauth2_client).with("slack_bot").returns(client)

      get oauth_callback_url(:slack_bot, code: "abc", state: "state-123")

      assert_redirected_to edit_organization_url(@organization)
      @organization.reload
      assert_equal "T9999", @organization.slack_team_id
      assert_equal "Acme Workspace", @organization.slack_team_name
      assert_equal "xoxb-bot-token", @organization.slack_access_token
    end

    test "callback reports already-connected when team id is taken" do
      create(:organization, slack_team_id: "T9999")
      OauthController.any_instance.stubs(:oauth_session_state).returns("state-123")
      token = stub(
        token: "xoxb-bot-token",
        params: {"team" => {"id" => "T9999", "name" => "Acme Workspace"}}
      )
      client = stub
      auth_code = stub
      client.stubs(:auth_code).returns(auth_code)
      auth_code.stubs(:get_token).returns(token)
      OauthToken.stubs(:oauth2_client).with("slack_bot").returns(client)

      get oauth_callback_url(:slack_bot, code: "abc", state: "state-123")

      assert_redirected_to edit_organization_url(@organization)
      assert_match(/already connected/, flash[:alert])
      assert_nil @organization.reload.slack_team_id
    end
  end
end
