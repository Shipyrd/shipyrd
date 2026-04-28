class Webhook < ApplicationRecord
  belongs_to :user
  belongs_to :application
  has_one :channel, as: :owner, dependent: :destroy

  validates :url, presence: true, url: {no_local: true, schemes: ["https"]}

  after_create :create_channel

  def create_channel
    create_channel!(
      application: application,
      channel_type: :webhook,
      events: Channel::EVENTS
    )
  end

  def notify(event, details)
    logger.debug "Notifying #{url} of #{event} with #{details}"

    uri, pinned_ip = UrlSafety.verify!(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10
    # Pin the connection to the verified IP so a DNS rebind between verify!
    # and the actual request cannot redirect us to a private host. The
    # original hostname is retained for SNI / certificate verification.
    http.ipaddr = pinned_ip

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {event: event}.merge(details).to_json

    http.start { |conn| conn.request(request) }
  rescue UrlSafety::BlockedHostError => e
    logger.warn "Refusing webhook to #{url}: #{e.message}"
  end
end
