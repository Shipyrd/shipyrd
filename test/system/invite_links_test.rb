require "application_system_test_case"

class InviteLinksTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, role: :admin, password: "password")
    sign_in(@user.email, "password")
  end

  test "should create invite link" do
    visit users_url
    click_on "Invite a user to Shipyrd"

    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_user", with: new_user_url(code: InviteLink.active_for_role(:user).code)
  end

  test "should deactivate Invite link" do
    @invite_link = create(:invite_link, role: :user)

    visit users_url
    click_on "Deactivate user invite link"

    assert_text "Invite link was successfully deactivated"
  end
end
