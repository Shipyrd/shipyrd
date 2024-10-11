require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    @admin = create(:user, role: :admin, password: "password")
    sign_in_as(@admin.email, "password")
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h4", text: "Users"
    assert_selector "h4", text: "Admins"
  end
end
