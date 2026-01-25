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
end
