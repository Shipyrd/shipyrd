require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  describe "viewing users" do
    setup do
      @organization = create(:organization)

      @user = create(:user, role: :user)
      @organization.users << @user

      @admin = create(:user, role: :admin)
      @organization.users << @admin

      @other_user = create(:user, role: :user)
      create(:organization).users << @other_user

      sign_in_as(@admin.email, @admin.password)
    end

    test "groups" do
      visit users_url

      refute_selector(:xpath, ".//button[@title='#{@other_user.display_name}']")
      assert_selector(:xpath, ".//button[@title='#{@user.display_name}']")
      assert_selector(:xpath, ".//button[@title='#{@admin.display_name}']")
      assert_selector "h4", text: "Users"
      assert_selector "h4", text: "Admins"
    end
  end

  describe "signup" do
    test "creating a user" do
      @user = build(:user)

      visit new_user_url

      fill_in "Name", with: @user.name
      fill_in "Organization name", with: "Initech"
      fill_in "GitHub username", with: @user.username
      fill_in "Email", with: @user.email
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "Create your first application"
    end
  end

  describe "invite links" do
    setup do
      @organization = create(:organization)
    end

    test "creating via user invite link" do
      code = InviteLink.create!(role: :user, organization: @organization).code

      visit new_user_url(code: code)

      assert_no_field "Organization name"

      fill_in "Name", with: "New User"
      fill_in "GitHub username", with: "newuser"
      fill_in "Email", with: "new@example.com"
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "User was successfully created"
      assert_text "Create your first application"

      visit users_url
      assert_text "Create your first application"
    end

    test "creating via admin invite link" do
      code = InviteLink.create!(role: :admin, organization: @organization).code

      visit new_user_url(code: code)

      fill_in "Name", with: "New User"
      fill_in "GitHub username", with: "newuser"
      fill_in "Email", with: "new@example.com"
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "User was successfully created"
      assert_text "Create your first application"

      visit users_url
      assert_text "Invite a user to Shipyrd"
    end
  end
end
