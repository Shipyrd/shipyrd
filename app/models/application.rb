class Application < ApplicationRecord
  has_many :deploys, dependent: :destroy, foreign_key: :service, primary_key: :key, inverse_of: "application"
  has_many :destinations, dependent: :destroy

  broadcasts_refreshes # For broadcasting on the index before there's an application record
  broadcasts # For broadcasting deploys as they come in

  validates :key, presence: true

  accepts_nested_attributes_for :destinations, allow_destroy: true

  def destination_names
    destinations.group(:name).pluck(:name)
  end

  def display_name
    name || key
  end

  def current_status(destination:)
    latest_deploy(destination: destination).status
  end

  def latest_deploy(destination:)
    deploys.where(destination: destination, command: :deploy).last
  end
end
