require "test_helper"
require "helpers/basic_auth_helpers"

class UsersControllerTest < ActionDispatch::IntegrationTest
  describe "unauthenticated" do
    test "should get new" do
      get new_user_url
      assert_response :success
    end

    describe "creating a user" do
      test "should create user without invite link" do
        user = build(:user)

        assert_difference("User.count") do
          post users_url, params: {user: {organization_name: "Initech", email: user.email, name: user.name, password: "secretsecret", username: user.username}}
        end

        user = User.last

        assert_redirected_to root_url
        assert user
        assert_equal "Initech", user.organizations.last.name
        assert user.admin?
      end

      describe "via invite link" do
        setup do
          @organization = create(:organization)
        end

        test "with invalid invite link" do
          user = build(:user)

          assert_no_difference("User.count") do
            post users_url, params: {code: "heyo", user: {email: user.email, name: user.name, password: "secretsecret", username: user.username}}
          end

          assert_response :unprocessable_entity
        end

        test "should create user" do
          invite_link = @organization.invite_links.create!(role: :user)
          user = build(:user)

          assert_no_difference("User.count") do
            post users_url, params: {code: invite_link.code, user: {email: user.email, name: user.name, username: user.username}}
          end

          assert_response :unprocessable_entity

          assert_difference("User.count") do
            post users_url, params: {code: invite_link.code, user: {email: user.email, name: user.name, password: "secretsecret", username: user.username}}
          end

          user = User.last

          assert_redirected_to root_url
          assert user
          assert_equal user.organizations.last, @organization
        end

        test "should create an admin" do
          invite_link = @organization.invite_links.create!(role: :admin)
          user = build(:user)

          assert_difference("User.count") do
            post users_url, params: {code: invite_link.code, user: {email: user.email, name: user.name, password: "secretsecret", username: user.username}}
          end

          user = User.last

          assert_redirected_to root_url
          assert user.admin?
          assert_equal user.organizations.last, @organization
        end
      end
    end
  end

  describe "authenticated" do
    setup do
      @organization = create(:organization)
    end

    describe "admin" do
      setup do
        @admin = create(:user, role: :admin)
        @organization.users << @admin
        sign_in(@admin.email, @admin.password)
      end

      test "should get index" do
        get users_url
        assert_response :success
      end

      test "should destroy user" do
        @user = create(:user)
        @organization.users << @user

        assert_difference("User.count", -1) do
          delete user_url(@user)
        end

        assert_redirected_to users_url
      end

      test "should only destroy organization users" do
        @other_user = create(:user, role: :user)
        create(:organization).users << @other_user

        assert_no_difference("User.count") do
          delete user_url(@other_user)
        end

        assert_response :not_found
      end
    end

    describe "user" do
      setup do
        @user = create(:user, role: :user)
        @organization.users << @user
        sign_in(@user.email, @user.password)
      end

      test "should not get index" do
        get users_url
        assert_redirected_to root_url
      end

      test "should show user" do
        get user_url(@user)
        assert_response :success
      end

      test "should not destroy user" do
        assert_no_difference("User.count", -1) do
          delete user_url(@user)
        end

        assert_redirected_to root_url
      end

      test "should not edit someone else" do
        get edit_user_url(create(:user, role: :user))
        assert_response :not_found
      end

      test "should not update someone else" do
        other_user = create(:user, role: :user)
        patch user_url(other_user), params: {user: {email: @user.email, name: @user.name, password: "secretsecret", username: @user.username}}

        assert_response :not_found
      end

      test "should get edit for self" do
        get edit_user_url(@user)
        assert_response :success
      end

      test "should update current user" do
        patch user_url(@user), params: {user: {email: @user.email, name: @user.name, password: "secretsecret", username: @user.username}}
        assert_redirected_to user_url(@user)
      end
    end
  end
end
