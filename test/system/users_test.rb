require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  describe "viewing users" do
    setup do
      @user = create(:user, role: :user)
      @admin = create(:user, role: :admin)

      sign_in_as(@admin.email, @admin.password)
    end

    test "groups" do
      visit users_url
      assert_selector "h4", text: "Users"
      assert_selector "h4", text: "Admins"
    end
  end

  describe "invite links" do
    test "creating via user invite link" do
      code = InviteLink.create(role: :user).code

      visit new_user_url(code: code)

      fill_in "Name", with: "New User"
      fill_in "GitHub username", with: "newuser"
      fill_in "Email", with: "new@example.com"
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "User was successfully created"
      assert_text "Waiting for a deploy to start..."

      visit users_url
      assert_text "Waiting for a deploy to start..."
    end

    test "creating via admin invite link" do
      code = InviteLink.create(role: :admin).code

      visit new_user_url(code: code)

      fill_in "Name", with: "New User"
      fill_in "GitHub username", with: "newuser"
      fill_in "Email", with: "new@example.com"
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "User was successfully created"
      assert_text "Waiting for a deploy to start..."

      visit users_url
      assert_text "Invite a user to Shipyrd"
    end
  end
end
