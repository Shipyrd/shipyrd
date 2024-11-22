class Organization < ApplicationRecord
  has_secure_token

  has_many :invite_links, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :memberships, counter_cache: true
  has_many :users, through: :memberships
end
