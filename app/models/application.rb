class Application < ApplicationRecord
  has_secure_token

  belongs_to :organization, counter_cache: true
  has_many :deploys, dependent: :destroy, inverse_of: "application"
  has_many :connections, dependent: :destroy
  has_many :destinations, dependent: :destroy do
    def find_or_create_with_hosts(hosts_string:, name:)
      destination = find_or_create_by!(name: name)

      return if hosts_string.blank?

      hosts = hosts_string.split(",")

      return destination if destination.servers.where(host: hosts).count == hosts.count

      hosts.each do |host|
        destination.servers.find_or_create_by!(host: host)
      end

      destination
    end
  end

  broadcasts_refreshes # For broadcasting on the index before there's an application record
  broadcasts # For broadcasting deploys as they come in

  accepts_nested_attributes_for :destinations, allow_destroy: true

  def destination_names
    destinations.group(:name).pluck(:name)
  end

  def display_name
    name.presence || key
  end

  def current_status(destination:)
    latest_deploy(destination: destination).status
  end

  def latest_deploy(destination:)
    deploys.where(destination: destination, command: :deploy).last
  end

  def repository_name
    repository_url.split("/").last
  end

  def repository_username
    repository_url.split("/").slice(-2)
  end

  def github_connection
    connections.find_by(provider: "github")
  end
end
