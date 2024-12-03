require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  it "can check for admin status for a user" do
    organization = create(:organization)
    user = create(:user)

    refute organization.admin?(user)

    organization.memberships.create(user: user, role: :admin)
    assert organization.admin?(user)
  end
end
