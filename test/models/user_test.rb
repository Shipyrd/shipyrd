require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "populate_avatar_url" do
    it "with unknown username" do
      stub_request(:get, "https://api.github.com/users/haxor").
        to_return(
          body: { message: "Not Found" }.to_json,
          status: 404
          )

      user = create(:user, username: "haxor")

      user.populate_avatar_url

      assert_nil user.avatar_url
    end

    it "with known username" do
      stub_request(:get, "https://api.github.com/users/nickhammond").
        to_return(
          body: { avatar_url: "https://avatars.githubusercontent.com/u/17698?v=4" }.to_json,
          status: 404
        )

      user = create(:user, username: "nickhammond")

      user.populate_avatar_url

      assert_equal user.avatar_url, "https://avatars.githubusercontent.com/u/17698?v=4&s=100"
    end
  end
end
