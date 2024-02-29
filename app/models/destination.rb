class Destination < ApplicationRecord
  belongs_to :application, foreign_key: :destination, primary_key: :name, optional: true
  has_many :deploys, through: :application
end
