class InviteLink < ApplicationRecord
  include Role

  class AlreadyRedeemed < RuntimeError; end

  belongs_to :creator, class_name: "User", optional: true
  belongs_to :organization
  belongs_to :redeemed_by, class_name: "User", optional: true,
    foreign_key: :redeemed_by_user_id
  has_secure_token :code, length: 64

  validates :role, inclusion: {in: roles.keys}

  before_validation :set_expiration

  scope :active, -> {
    where(deactivated_at: nil, expires_at: Time.current..)
      .where("role != ? OR redeemed_at IS NULL", roles[:admin])
  }
  scope :for_role, ->(role) { where(role: role) }

  def self.active_for_role(role)
    active.find_by(role: role)
  end

  def single_use?
    admin?
  end

  def accept!(user)
    transaction do
      if single_use?
        lock!
        raise AlreadyRedeemed, "Invite link has already been redeemed" if redeemed_at.present?
      end

      membership = organization.memberships.find_or_create_by(user: user) do |m|
        m.role = role
      end

      update!(redeemed_at: Time.current, redeemed_by: user) if single_use?
      membership
    end
  end

  def deactivate!
    update(deactivated_at: Time.current)
  end

  def deactivated?
    deactivated_at.present?
  end

  private

  def set_expiration
    self.expires_at = 24.hours.from_now
  end
end
