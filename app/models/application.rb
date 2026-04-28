class Application < ApplicationRecord
  has_secure_token length: 64
  has_secure_token :badge_key

  belongs_to :organization, counter_cache: true
  has_many :deploys, dependent: :destroy, inverse_of: "application"
  has_many :oauth_tokens, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :incoming_webhooks, dependent: :destroy
  has_one :github_installation, dependent: :destroy
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

  validates :repository_url, url: {allow_blank: true, no_local: true}

  broadcasts_refreshes # When an application is created, updated, or destroyed a refresh is streamed to "applications"
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
    deploys.where(destination: destination, command: [:deploy, :setup]).last
  end

  def hosted_on_github?
    return false if repository_url.blank?
    URI.parse(repository_url).host&.downcase == "github.com"
  rescue URI::InvalidURIError
    false
  end

  def repository_name
    repository_url.split("/").last
  end

  def repository_username
    repository_url.split("/").slice(-2)
  end

  def repository_full_name
    return nil if repository_url.blank?
    "#{repository_username}/#{repository_name}"
  end

  def matches_github_repository?(repositories)
    return false if repository_full_name.blank?
    repositories.any? { |r| r[:full_name].casecmp?(repository_full_name) }
  end
end
