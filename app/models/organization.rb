class Organization < ApplicationRecord
  has_secure_token

  has_many :applications, counter_cache: true, dependent: :destroy
  has_many :memberships, counter_cache: true
  has_many :users, through: :memberships
end
