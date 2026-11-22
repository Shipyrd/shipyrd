class Application < ApplicationRecord
  has_secure_token length: 64
  has_secure_token :badge_key

  belongs_to :organization, counter_cache: true
  has_many :deploys, dependent: :destroy, inverse_of: "application"
  has_many :oauth_tokens, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :incoming_webhooks, dependent: :destroy
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
  validates :slug,
    presence: true,
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "may only contain lowercase letters, numbers, and dashes"},
    uniqueness: {scope: :organization_id, case_sensitive: false}

  before_validation :generate_slug

  broadcasts_refreshes # When an application is created, updated, or destroyed a refresh is streamed to "applications"
  broadcasts # For broadcasting deploys as they come in

  accepts_nested_attributes_for :destinations, allow_destroy: true

  def destination_names
    destinations.group(:name).pluck(:name)
  end

  # Newest first, the dashboard's order. No `includes(:locker)` here: the
  # dashboard only names the locker of a destination that is locked, so eager
  # loading it is wasted on most rows and Bullet flags it as unused.
  def destinations_by_recency
    DestinationDeployState.preload(destinations.latest)
  end

  # One per name, alphabetical, the API's order. (application_id, name) is not a
  # unique index, so two rows can share a name — `destination_names` dedupes
  # with group(:name) for the same reason. `includes(:locker)` because the JSON
  # reports `locked_by` for every destination, and Bullet raises on that N+1 as
  # soon as an application has two of them.
  def destinations_by_name
    DestinationDeployState.preload(destinations.order(:name).includes(:locker).uniq(&:name))
  end

  def display_name
    name.presence || slug
  end

  def current_status(destination:)
    latest_deploy(destination: destination).status
  end

  def latest_deploy(destination:)
    deploys.where(destination: destination, command: [:deploy, :setup]).last
  end

  def repository_name
    repository_url.split("/").last
  end

  def repository_username
    repository_url.split("/").slice(-2)
  end

  private

  def generate_slug
    return if slug.present?

    base = (name.presence || key).to_s.parameterize
    return if base.blank?

    candidate = base
    counter = 1
    scope = self.class.where(organization_id: organization_id)
    scope = scope.where.not(id: id) if persisted?

    while scope.where(slug: candidate).exists?
      counter += 1
      candidate = "#{base}-#{counter}"
    end

    self.slug = candidate
  end
end
