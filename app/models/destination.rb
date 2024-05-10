class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  has_many :deploys, through: :application
end
