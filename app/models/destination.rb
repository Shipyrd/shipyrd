require "net/http"
require "uri"

class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  belongs_to :locker, class_name: "User", optional: true, foreign_key: :locked_by_user_id
  has_many :deploys, through: :application
  has_many :servers, dependent: :destroy
  has_many :channels, through: :application

  scope :latest, -> { order(created_at: :desc) }

  validates :url, url: {allow_blank: true, no_local: true}

  before_save :schedule_favicon_fetch_if_url_changed

  broadcasts

  def application_name
    application.name
  end

  def new_servers_available?
    servers.where(last_connected_at: nil).any?
  end

  def recipe_path
    "config/#{recipe_name}"
  end

  def recipe_name
    "deploy#{".#{name}" if name.present?}.yml"
  end

  def dispatch_notifications(event, details)
    channels.each do |channel|
      next unless channel.events.include?(event.to_s)

      channel.notifications.create!(
        event: event,
        destination: self,
        details: details
      )
    end
  end

  def locked?
    locked_at.present?
  end

  def locked_by
    locker&.display_name
  end

  def lock!(user)
    update!(
      locked_at: Time.current,
      locker: user
    )

    dispatch_notifications(:lock, {locked_at: Time.current, user_id: user.id})
  end

  def unlock!(user)
    update!(
      locked_at: nil,
      locker: nil
    )

    dispatch_notifications(:unlock, {user_id: user.id})
  end

  def on_deck_url
    return nil if application.repository_url.blank?
    return nil if latest_deployed_sha.blank? || latest_deployed_sha =~ /uncommitted/
    return nil if branch.blank?

    "#{application.repository_url}/compare/#{latest_deployed_sha}...#{branch}"
  end

  def latest_deployed_sha
    @latest_deployed_sha ||= deploys.where(
      destination: name,
      command: :deploy,
      status: "post-deploy"
    ).last&.version
  end

  def display_name
    name.presence || "default"
  end

  def default?
    name.blank?
  end

  def production?
    name == "production"
  end

  private

  def schedule_favicon_fetch_if_url_changed
    return unless url_changed? && url.present?

    # Schedule favicon fetch in background after save
    after_commit { FaviconFetchJob.perform_later(id) }
  end

  def fetch_favicon
    return nil unless url.present?

    begin
      uri = URI.parse(url)
      # Only process HTTP and HTTPS URLs
      return nil unless %w[http https].include?(uri.scheme)
      
      base_url = "#{uri.scheme}://#{uri.host}"
      base_url += ":#{uri.port}" if uri.port && ![80, 443].include?(uri.port)

      # Try common favicon locations first
      favicon_urls = [
        "#{base_url}/favicon.ico",
        "#{base_url}/apple-touch-icon.png",
        "#{base_url}/apple-touch-icon-precomposed.png"
      ]

      favicon_urls.each do |favicon_url|
        if favicon_exists?(favicon_url)
          return favicon_url
        end
      end

      # If no common favicon found, try to parse HTML for favicon link
      parse_favicon_from_html(base_url)
    rescue URI::InvalidURIError, SocketError, Net::OpenTimeout, Net::ReadTimeout, StandardError => e
      Rails.logger.warn "Failed to fetch favicon for URL #{url}: #{e.message}"
      nil
    end
  end

  def favicon_exists?(favicon_url)
    begin
      response = http_get_with_timeout(favicon_url)
      response.code == "200" && response.content_type&.start_with?("image/")
    rescue StandardError
      false
    end
  end

  def parse_favicon_from_html(base_url)
    begin
      response = http_get_with_timeout(base_url)
      return nil unless response.code == "200"

      html = response.body
      # Look for favicon link in HTML - support multiple variations
      favicon_match = html.match(/<link[^>]*rel=["'](?:icon|shortcut icon|apple-touch-icon)["'][^>]*href=["']([^"']+)["']/i)
      
      if favicon_match
        favicon_path = favicon_match[1]
        # Convert relative URLs to absolute
        if favicon_path.start_with?("//")
          uri = URI.parse(base_url)
          "#{uri.scheme}:#{favicon_path}"
        elsif favicon_path.start_with?("/")
          "#{base_url}#{favicon_path}"
        elsif favicon_path.start_with?("http")
          favicon_path
        else
          "#{base_url}/#{favicon_path}"
        end
      end
    rescue StandardError => e
      Rails.logger.warn "Failed to parse favicon from HTML for #{base_url}: #{e.message}"
      nil
    end
  end

  def http_get_with_timeout(url_string, timeout_seconds = 5)
    uri = URI(url_string)
    
    Net::HTTP.start(uri.host, uri.port, 
                   use_ssl: uri.scheme == 'https',
                   open_timeout: timeout_seconds,
                   read_timeout: timeout_seconds) do |http|
      http.get(uri.path.empty? ? '/' : uri.path)
    end
  end
end
