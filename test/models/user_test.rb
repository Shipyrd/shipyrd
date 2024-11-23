require "test_helper"

class UserTest < ActiveSupport::TestCase
  it "display_name" do
    user = build(:user, username: "username")

    assert_equal "username", user.display_name

    user.username = nil
    user.name = "Nick"

    assert_equal "Nick", user.display_name
  end

  describe "populate_avatar_url" do
    it "with github username" do
      user = build(:user)

      stub_request(:get, "https://api.github.com/users/#{user.username}")
        .to_return(
          body: {avatar_url: "https://avatars.githubusercontent.com/u/17698?v=4"}.to_json
        )

      user.populate_avatar_url
      user.reload

      assert_equal "https://avatars.githubusercontent.com/u/17698?v=4&s=100", user.avatar_url
    end
  end
end
