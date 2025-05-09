class Organization < ApplicationRecord
  has_secure_token

  has_many :invite_links, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  def admin?(user)
    memberships.exists?(user: user, role: :admin)
  end
end
