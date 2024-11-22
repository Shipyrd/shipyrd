class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization, counter_cache: true
end
