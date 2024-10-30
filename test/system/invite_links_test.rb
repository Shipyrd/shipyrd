require "application_system_test_case"

class InviteLinksTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, role: :admin, password: "password")
    sign_in_as(@user.email, "password")
  end

  test "should create and destroy invite link" do
    sleep(1)

    visit users_url
    click_on "Invite a user to Shipyrd"

    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_user", with: new_user_url(code: InviteLink.active_for_role(:user).code)

    click_on "Deactivate user invite link"

    assert_text "Invite link was successfully deactivated"

    click_on "Invite an admin to Shipyrd"
    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_admin", with: new_user_url(code: InviteLink.active_for_role(:admin).code)

    click_on "Deactivate admin invite link"
    assert_text "Invite link was successfully deactivated"
  end
end
