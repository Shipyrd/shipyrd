require "test_helper"
require "helpers/basic_auth_helpers"

class InviteLinksControllerTest < ActionDispatch::IntegrationTest
  before do
    @api_key = ApiKey.create!
    @auth_headers = auth_headers(@api_key.token)
  end

  test "should create invite_link with role" do
    assert_difference("InviteLink.active.for_role(:user).count") do
      post invite_links_url, params: {invite_link: {role: :user}}, headers: @auth_headers
    end

    assert_redirected_to users_url
  end

  test "should deactivate invite_link" do
    @invite_link = create(:invite_link)
    delete invite_link_url(@invite_link), headers: @auth_headers

    assert @invite_link.reload.deactivated?
    assert_redirected_to users_url
  end
end
