require "test_helper"
require "helpers/basic_auth_helpers"

class InviteLinksControllerTest < ActionDispatch::IntegrationTest
  describe "anonymous" do
    it "denies access" do
      post invite_links_url, params: {invite_link: {role: :user}}

      assert_response 302
    end
  end

  describe "authenticated" do
    setup do
      @organization = create(:organization)
    end

    describe "user" do
      setup do
        @user = create(:user)
        @organization.memberships.create(user: @user)

        sign_in(@user.email, @user.password)
      end

      it "can't create invite link" do
        assert_no_difference("InviteLink.active.for_role(:user).count") do
          post invite_links_url, params: {invite_link: {role: :user}}
        end

        assert_redirected_to root_url
      end
    end

    describe "admin" do
      setup do
        @user = create(:user)
        @organization.memberships.create(user: @user, role: :admin)
        sign_in(@user.email, @user.password)
      end

      test "should create invite_link with role" do
        assert_difference("InviteLink.active.for_role(:user).count") do
          post invite_links_url, params: {invite_link: {role: :user}}
        end

        assert_redirected_to users_url

        assert_difference("InviteLink.active.for_role(:admin).count") do
          post invite_links_url, params: {invite_link: {role: :admin}}
        end

        assert_redirected_to users_url
      end

      test "should deactivate invite_link" do
        @invite_link = create(:invite_link, organization: @organization)
        delete invite_link_url(@invite_link)

        assert @invite_link.reload.deactivated?
        assert_redirected_to users_url
      end
    end
  end
end
