class Organization < ApplicationRecord
  has_secure_token

  has_many :invite_links, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  def admin?(user)
    memberships.exists?(user: user, role: :admin)
  end

  def active_subscription?
    stripe_subscription_status == "active"
  end

  def subscription_state_label
    stripe_subscription_status&.humanize || "Trial"
  end

  def trial_active?
    return false if active_subscription?

    created_at > 45.days.ago
  end

  def payment_required?
    return false if ENV["COMMUNITY_EDITION"] != "0"

    !active_subscription? && !trial_active?
  end

  def business_hours_configured?
    time_zone.present? && business_hours_start.present? && business_hours_end.present?
  end

  def within_business_hours?
    return true unless business_hours_configured?

    current_time = Time.current.in_time_zone(time_zone)
    current_hour = current_time.hour

    if business_hours_start < business_hours_end
      current_hour >= business_hours_start && current_hour < business_hours_end
    else
      current_hour >= business_hours_start || current_hour < business_hours_end
    end
  end

  def outside_business_hours?
    !within_business_hours?
  end
end
