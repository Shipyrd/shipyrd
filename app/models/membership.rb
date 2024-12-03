class Membership < ApplicationRecord
  include Role
  belongs_to :user
  belongs_to :organization, counter_cache: :users_count
end
