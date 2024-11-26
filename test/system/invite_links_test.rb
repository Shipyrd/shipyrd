require "application_system_test_case"

class InviteLinksTest < ApplicationSystemTestCase
  test "should create and destroy invite link" do
    @user = create(:user, role: :admin)
    @organization = create(:organization)
    @organization.users << @user

    sign_in_as(@user.email, @user.password)

    visit users_url

    click_on "Invite a user to #{@organization.name}"

    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_user", with: new_user_url(code: @organization.invite_links.active_for_role(:user).code)

    click_on "Deactivate user invite link"
    assert_text "Invite link was successfully deactivated"

    click_on "Invite an admin to #{@organization.name}"
    assert_text "Invite link was successfully created"
    assert_field "invite_link_code_admin", with: new_user_url(code: @organization.invite_links.active_for_role(:admin).code)

    click_on "Deactivate admin invite link"
    assert_text "Invite link was successfully deactivated"
  end
end
