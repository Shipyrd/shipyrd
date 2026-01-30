require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  it "can check for admin status for a user" do
    organization = create(:organization)
    user = create(:user)

    refute organization.admin?(user)

    organization.memberships.create(user: user, role: :admin)
    assert organization.admin?(user)
  end

  it "returns true for active_subscription? when status is active" do
    organization = create(:organization)
    refute organization.active_subscription?

    organization.update!(stripe_subscription_status: "active")
    assert organization.active_subscription?

    organization.update!(stripe_subscription_status: "canceled")
    refute organization.active_subscription?
  end
end
