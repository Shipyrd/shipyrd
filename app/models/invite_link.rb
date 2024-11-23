class InviteLink < ApplicationRecord
  include Role

  belongs_to :creator, class_name: "User", optional: true
  belongs_to :organization
  has_secure_token :code, length: 64

  validates :role, inclusion: {in: roles.keys}

  before_validation :set_expiration

  scope :active, -> { where(deactivated_at: nil, expires_at: Time.current..) }
  scope :for_role, ->(role) { where(role: role) }

  def self.active_for_role(role)
    active.find_by(role: role)
  end

  def deactivate!
    update(deactivated_at: Time.current)
  end

  def deactivated?
    deactivated_at.present?
  end

  private

  def set_expiration
    self.expires_at = 3.hours.from_now
  end
end
