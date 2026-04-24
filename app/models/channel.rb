class Channel < ApplicationRecord
  belongs_to :application
  belongs_to :owner, polymorphic: true, dependent: :destroy, optional: true
  has_many :notifications, dependent: :destroy

  enum :channel_type, {
    github: 1,
    slack: 2,
    webhook: 3
  }

  serialize :events, coder: JSON
  normalizes :events, with: ->(events) { events.compact_blank }

  EVENTS = %w[deploy lock unlock]

  def self.available_notification_channels
    channels = []

    channels << :webhook
    channels << :slack if OauthToken.configured_providers.include?("slack")
    channels << :github if ENV["SHIPYRD_GITHUB_APP_ID"].present? && ENV["SHIPYRD_GITHUB_APP_SLUG"].present?

    channels
  end

  def display_name
    channel_type.humanize
  end
end
