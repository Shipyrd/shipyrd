require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "invitable_roles" do
    it "adminless" do
      assert_equal [:admin], User.invitable_roles
    end

    it "with password-based users" do
      create(:admin, password: "secret")
      assert_equal User.roles.keys, User.invitable_roles
    end
  end

  describe "populate_avatar_url" do
    it "with github username" do
      stub_request(:get, "https://api.github.com/users/nickhammond")
        .to_return(
          body: {avatar_url: "https://avatars.githubusercontent.com/u/17698?v=4"}.to_json
        )

      user = User.find_or_create_performer("https://github.com/nickhammond")
      user.reload

      assert_equal "https://avatars.githubusercontent.com/u/17698?v=4&s=100", user.avatar_url
    end
  end

  describe "find_or_create_performer" do
    it "with new user" do
      assert_difference("User.count") do
        assert User.find_or_create_performer("greta")
      end

      assert_difference("User.count") do
        User.any_instance.expects(:populate_avatar_url)
        assert User.find_or_create_performer("https://github.com/nick")
      end
    end

    it "with existing user" do
      user = User.find_or_create_performer("greta")

      assert_equal user, User.find_or_create_performer("greta")
      assert_equal user, User.find_or_create_performer("https://github.com/greta")
    end
  end
end
