require "application_system_test_case"
require "helpers/basic_auth_helpers"

class InviteLinksTest < ApplicationSystemTestCase
  setup do
    @api_key = ApiKey.create!
    visit basic_auth_url(root_url, @api_key.token)
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
