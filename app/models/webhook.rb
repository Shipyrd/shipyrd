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
    details = details.symbolize_keys
    return if event == :deploy && !%w[post-deploy failed].include?(details[:status].to_s)

    logger.debug "Notifying #{url} of #{event} with #{details}"

    Faraday.new(request: {timeout: 10, open_timeout: 5}) do |f|
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
