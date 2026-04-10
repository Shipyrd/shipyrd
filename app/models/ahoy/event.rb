class Ahoy::Event < ApplicationRecord
  self.table_name = "ahoy_events"

  include Ahoy::QueryMethods

  belongs_to :visit
  belongs_to :user, optional: true
end
