class Application < ApplicationRecord
  has_many :deploys, dependent: :destroy, foreign_key: :service, primary_key: :key

  broadcasts

  validates :key, presence: true

  def destination_names
    destinations.map do |d|
      d.present? ? d.humanize : 'Default'
    end
  end

  def display_name
    name || key
  end

  def destinations
    deploys.group(:destination).pluck(:destination)
  end

  def current_status(destination:)
    latest_deploy(destination: destination).status
  end

  def latest_deploy(destination:)
    deploys.where(destination: destination, command: :deploy).last
  end
end
