require "test_helper"

class InviteLinkTest < ActiveSupport::TestCase
  setup do
    @organization = create(:organization)
  end

  test "active_link_for returns first active invite link for role" do
    invite_link = create(:invite_link, role: :user, organization: @organization)

    assert_equal invite_link, InviteLink.active_for_role(:user)
  end

  test "deactivate! sets deactivated_at" do
    invite_link = create(:invite_link, organization: @organization)
    invite_link.deactivate!

    assert_not_nil invite_link.deactivated_at
    assert invite_link.deactivated?
  end

  test "expires_at is set with validation" do
    invite_link = create(:invite_link, organization: @organization)

    assert_not_nil invite_link.expires_at
  end
end
