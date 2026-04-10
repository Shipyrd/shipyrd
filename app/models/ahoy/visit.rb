class Ahoy::Visit < ApplicationRecord
  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true
end
