require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "populate_avatar_url" do
    it "with local user" do
      user = create(:user, username: "haxor")

      assert_equal "haxor", user.username
      assert_nil user.avatar_url
    end

    it "with known username" do
      stub_request(:get, "https://api.github.com/users/nickhammond").
        to_return(
          body: { avatar_url: "https://avatars.githubusercontent.com/u/17698?v=4" }.to_json,
          status: 404
        )

      user = create(:user, username: "https://github.com/nickhammond")

      assert_equal "nickhammond", user.username
      assert_equal "https://avatars.githubusercontent.com/u/17698?v=4&s=100", user.avatar_url
    end
  end
end
