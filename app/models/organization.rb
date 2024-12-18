class Organization < ApplicationRecord
  has_secure_token

  has_many :invite_links, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :oauth_tokens, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :webhooks, dependent: :destroy, through: :applications

  def admin?(user)
    memberships.exists?(user: user, role: :admin)
  end
end
