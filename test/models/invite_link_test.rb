require "test_helper"

class InviteLinkTest < ActiveSupport::TestCase
  test "active_link_for returns first active invite link for role" do
    invite_link = create(:invite_link, role: :user)

    assert_equal invite_link, InviteLink.active_for_role(:user)
  end

  test "deactivate! sets deactivated_at" do
    invite_link = create(:invite_link)
    invite_link.deactivate!

    assert_not_nil invite_link.deactivated_at
    assert invite_link.deactivated?
  end

  test "expires_at is set with validation" do
    invite_link = create(:invite_link)

    assert_not_nil invite_link.expires_at
  end

  test "admin invite links are single_use" do
    assert build(:invite_link, role: :admin).single_use?
    refute build(:invite_link, role: :user).single_use?
  end

  test "accept! on an admin link marks redemption and refuses reuse" do
    invite_link = create(:invite_link, role: :admin)
    user_a = create(:user)
    user_b = create(:user)

    invite_link.accept!(user_a)

    invite_link.reload
    assert_not_nil invite_link.redeemed_at
    assert_equal user_a, invite_link.redeemed_by

    assert_raises(InviteLink::AlreadyRedeemed) { invite_link.accept!(user_b) }
    refute invite_link.organization.memberships.exists?(user: user_b)
  end

  test "accept! on a user link allows multiple redemptions and leaves redeemed_at nil" do
    invite_link = create(:invite_link, role: :user)
    user_a = create(:user)
    user_b = create(:user)

    invite_link.accept!(user_a)
    invite_link.accept!(user_b)

    invite_link.reload
    assert_nil invite_link.redeemed_at
    assert_nil invite_link.redeemed_by
    assert invite_link.organization.memberships.exists?(user: user_a)
    assert invite_link.organization.memberships.exists?(user: user_b)
  end

  test "active scope excludes redeemed admin links but keeps user links" do
    admin_link = create(:invite_link, role: :admin)
    user_link = create(:invite_link, role: :user)

    assert_includes InviteLink.active, admin_link
    assert_includes InviteLink.active, user_link

    admin_link.accept!(create(:user))
    user_link.accept!(create(:user))

    refute_includes InviteLink.active, admin_link.reload
    assert_includes InviteLink.active, user_link.reload
  end
end
