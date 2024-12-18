class Webhook < ApplicationRecord
  belongs_to :user
  belongs_to :application
  has_one :channel, as: :owner, dependent: :destroy

  validates :url, presence: true, url: {no_local: true}

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

    Faraday.new do |f|
      f.request :json
      f.response :logger, Rails.logger if Rails.env.development?
    end.post(url) do |r|
      r.headers["Content-Type"] = "application/json"
      r.body = {
        event: event
      }.merge(details).to_json
    end
  end
end
