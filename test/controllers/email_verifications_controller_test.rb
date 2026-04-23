require "test_helper"
require "helpers/basic_auth_helpers"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["COMMUNITY_EDITION"] = "0"
  end

  teardown do
    ENV.delete("COMMUNITY_EDITION")
  end

  describe "show (verify token)" do
    test "verifies email with valid token" do
      user = create(:user, :unverified)
      token = user.generate_token_for(:email_verification)

      get email_verification_url(token)

      assert_redirected_to root_path
      assert user.reload.email_verified?
    end

    test "rejects invalid token" do
      get email_verification_url("invalid-token")

      assert_redirected_to new_session_path
      assert_equal "Verification link is invalid or has expired.", flash[:alert]
    end

    test "rejects expired token" do
      user = create(:user, :unverified)
      token = user.generate_token_for(:email_verification)

      travel 25.hours do
        get email_verification_url(token)

        assert_redirected_to new_session_path
        assert_equal "Verification link is invalid or has expired.", flash[:alert]
      end
    end
  end

  describe "new (verification required page)" do
    test "shows verification page for unverified user past grace period" do
      user = create(:user, :verification_required)
      organization = create(:organization)
      organization.memberships.create!(user: user)
      sign_in(user.email, user.password)

      get new_email_verification_url

      assert_response :success
    end
  end

  describe "create (resend)" do
    test "resends verification email" do
      user = create(:user, :verification_required)
      organization = create(:organization)
      organization.memberships.create!(user: user)
      sign_in(user.email, user.password)

      assert_enqueued_emails 1 do
        post email_verifications_url
      end

      assert_redirected_to new_email_verification_path
    end
  end
end
