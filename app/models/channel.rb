class Channel < ApplicationRecord
  belongs_to :application
  belongs_to :owner, polymorphic: true, dependent: :destroy

  enum :channel_type, {
    github: 1,
    slack: 2,
    webhook: 3
  }

  serialize :events, coder: JSON
  normalizes :events, with: ->(events) { events.compact_blank }

  EVENTS = %w[deploy lock]

  def self.available_channels(owner_type)
    channels = []

    channels << :webhook
    channels << :github if OauthToken.configured_providers.include?("github")
    channels << :slack if OauthToken.configured_providers.include?("slack")

    channels
  end

  def display_name
    channel_type.humanize
  end
end
