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
end
