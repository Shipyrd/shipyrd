require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  describe "signing in" do
    it "links to sign up" do
      visit new_session_url
      assert_link "Sign up", href: new_user_path
    end
  end
end
