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

  describe "selected_time_zone" do
    it "returns the configured time zone when set" do
      organization = create(:organization, time_zone: "Central Time (US & Canada)")

      assert_equal ActiveSupport::TimeZone["Central Time (US & Canada)"], organization.selected_time_zone
    end

    it "falls back to Time.zone when time_zone is blank" do
      organization = create(:organization, time_zone: nil)

      assert_equal Time.zone, organization.selected_time_zone
    end
  end

  describe "business hours" do
    it "returns true for within_business_hours? when no time zone configured" do
      organization = create(:organization, time_zone: nil)

      assert organization.within_business_hours?
      refute organization.outside_business_hours?
    end

    it "returns true for within_business_hours? during business hours" do
      organization = create(:organization,
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17)

      # Simulate 12:00 PM Central
      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 12, 0, 0) do
        assert organization.within_business_hours?
        refute organization.outside_business_hours?
      end
    end

    it "returns false for within_business_hours? outside business hours" do
      organization = create(:organization,
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17)

      # Simulate 8:00 PM Central
      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 20, 0, 0) do
        refute organization.within_business_hours?
        assert organization.outside_business_hours?
      end
    end

    it "returns false for within_business_hours? before business hours start" do
      organization = create(:organization,
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17)

      # Simulate 7:00 AM Central
      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 7, 0, 0) do
        refute organization.within_business_hours?
      end
    end

    it "returns true at the exact start hour" do
      organization = create(:organization,
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17)

      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 9, 0, 0) do
        assert organization.within_business_hours?
      end
    end

    it "returns false at the exact end hour" do
      organization = create(:organization,
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17)

      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 17, 0, 0) do
        refute organization.within_business_hours?
      end
    end

    it "handles overnight business hours" do
      organization = create(:organization,
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 22,
        business_hours_end: 6)

      # 11 PM should be within business hours
      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 23, 0, 0) do
        assert organization.within_business_hours?
      end

      # 3 AM should be within business hours
      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 3, 0, 0) do
        assert organization.within_business_hours?
      end

      # 10 AM should be outside business hours
      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 10, 0, 0) do
        refute organization.within_business_hours?
      end
    end

    it "business_hours_configured? returns false without time zone" do
      organization = create(:organization, time_zone: nil)
      refute organization.business_hours_configured?
    end

    it "business_hours_configured? returns true with time zone" do
      organization = create(:organization, time_zone: "Central Time (US & Canada)")
      assert organization.business_hours_configured?
    end
  end

  describe "slack_team_id changes" do
    it "clears slack_user_id on memberships when team is disconnected" do
      organization = create(:organization, slack_team_id: "T123")
      membership = create(:membership, organization: organization, slack_user_id: "U123")

      organization.update!(slack_team_id: nil)

      assert_nil membership.reload.slack_user_id
    end

    it "clears slack_user_id on memberships when team is swapped" do
      organization = create(:organization, slack_team_id: "T123")
      membership = create(:membership, organization: organization, slack_user_id: "U123")

      organization.update!(slack_team_id: "T999")

      assert_nil membership.reload.slack_user_id
    end
  end
end
