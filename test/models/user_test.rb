require "test_helper"

class UserTest < ActiveSupport::TestCase
  it "display_name" do
    user = build(:user, username: "username")

    assert_equal "username", user.display_name

    user.username = nil
    user.name = "Nick"

    assert_equal "Nick", user.display_name
  end

  it "github_user?" do
    user = build(:user, username: "https://gitlab.com/nick")
    refute user.github_user?

    user.username = "https://github.com/nick"
    assert user.github_user?
  end

  it "github_username" do
    user = build(:user, username: "https://github.com/nick")

    assert_equal "nick", user.github_username
  end

  describe "populate_avatar_url" do
    it "with github username" do
      user = build(
        :user,
        username: "https://github.com/nick"
      )

      stub_request(:get, "https://api.github.com/users/nick")
        .to_return(
          body: {avatar_url: "https://avatars.githubusercontent.com/u/17698?v=4"}.to_json
        )

      user.populate_avatar_url
      user.reload

      assert_equal "https://avatars.githubusercontent.com/u/17698?v=4&s=100", user.avatar_url
    end
  end
end
