require "application_system_test_case"

class InviteLinksTest < ApplicationSystemTestCase
  test "should create and destroy invite link" do
    # First login is via API key
    ApiKey.create!

    url = URI.parse(root_url)
    url.userinfo = ":#{ApiKey.first.token}"

    visit url

    find(".navbar-item.has-dropdown").hover
    click_on "Users"

    # First invite should go to an admin
    refute_text "Invite a user to Shipyrd"
    click_on "Invite an admin to Shipyrd"

    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_admin", with: new_user_url(code: InviteLink.active_for_role(:admin).code)

    @user = create(:user, role: :admin, password: "password")
    sign_in_as(@user.email, "password")

    # Now that an admin has logged in, we can invite regular users
    visit users_url
    click_on "Invite a user to Shipyrd"

    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_user", with: new_user_url(code: InviteLink.active_for_role(:user).code)

    click_on "Deactivate user invite link"
    assert_text "Invite link was successfully deactivated"

    click_on "Deactivate admin invite link"
    assert_text "Invite link was successfully deactivated"
  end
end
