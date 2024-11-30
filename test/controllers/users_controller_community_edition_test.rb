require "test_helper"
require "helpers/basic_auth_helpers"

class UsersControllerTest < ActionDispatch::IntegrationTest
  describe "unauthenticated" do
    describe "community edition" do
      setup do
        ENV["COMMUNITY_EDITION"] = "1"
      end

      it "allows first user creation without invite" do
        user = build(:user)

        assert_difference("User.count") do
          post users_url, params: {user: {organization_name: "Initech", email: user.email, name: user.name, password: "secretsecret", username: user.username}}
        end

        user = User.last

        assert_redirected_to root_url
        assert user
        assert_equal "Initech", user.organizations.last.name
        assert user.organizations.last.admin?(user)
      end

      describe "organization created" do
        setup do
          @organization = create(:organization)
          @organization.memberships.create!(user: create(:user), role: :admin)
        end

        it "does not allow user creation without an invite link" do
          user = build(:user)

          get new_user_url
          assert_redirected_to new_session_url

          assert_no_difference("User.count") do
            post users_url, params: {user: {organization_name: "Initech", email: user.email, name: user.name, password: "secretsecret", username: user.username}}
          end

          assert_redirected_to new_session_url
        end

        it "allows user creation with invite link" do
          user = build(:user)
          invite_link = @organization.invite_links.create!(role: :admin)

          get new_user_url(code: invite_link.code)
          assert_response :success

          assert_difference("User.count") do
            post users_url, params: {code: invite_link.code, user: {email: user.email, name: user.name, password: "secretsecret", username: user.username}}
          end

          user = User.last

          assert_redirected_to root_url
          assert user.organizations.last.admin?(user)
          assert_equal user.organizations.last, @organization
        end
      end
    end
  end
end
