class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  belongs_to :visit
  belongs_to :user, optional: true
end
