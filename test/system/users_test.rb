require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  describe "viewing users" do
    setup do
      @organization = create(:organization)

      @user = create(:user)
      @organization.memberships.create(user: @user)

      @admin = create(:user)
      @organization.memberships.create(user: @admin, role: :admin)

      @other_user = create(:user)
      create(:organization).memberships.create(user: @other_user)

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

      assert_link "Sign in", href: new_session_path

      fill_in "Name", with: @user.name
      fill_in "Organization name", with: "Initech"
      fill_in "Email", with: @user.email
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "Create your first application"
    end
  end

  describe "invite links" do
    setup do
      @organization = create(:organization)
      @user = build(:user)
    end

    test "creating via user invite link" do
      code = InviteLink.create!(role: :user, organization: @organization).code

      visit new_user_url(code: code)

      assert_no_field "Organization name"

      fill_in "Name", with: @user.name
      fill_in "Email", with: @user.email
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

      fill_in "Name", with: @user.name
      fill_in "Email", with: @user.email
      fill_in "Password", with: "secretsecret"

      click_on "Create User"

      assert_text "User was successfully created"
      assert_text "Create your first application"

      visit users_url
      assert_text "Invite a user to #{@organization.name}"
    end
  end
end
