require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, role: :user)
    @admin = create(:user, role: :admin)

    sign_in_as(@admin.email, @admin.password)
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h4", text: "Users"
    assert_selector "h4", text: "Admins"
  end

  describe "invite links" do
    test "creating via invite link" do
      code = InviteLink.create(role: :user).code

      visit new_user_url(code: code)

      fill_in "Name", with: "New User"
      fill_in "GitHub username", with: "newuser"
      fill_in "Email", with: "new@example.com"
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "Waiting for a deploy to start..."
    end
  end
end
