class Channel < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :oauth_token, optional: true, dependent: :destroy

  enum :channel_type, {
    github: 1,
    slack: 2,
    webhook: 3
  }

  serialize :events, coder: JSON
  normalizes :events, with: ->(events) { events.reject(&:blank?) }

  EVENTS = {
    application: %w[deploy lock],
    organization: %w[user_joins admin_joins]
  }

  def self.available_channels
    channels = []

    channels << :github if OauthToken.configured_providers.include?("github")
    channels << :slack if OauthToken.configured_providers.include?("slack")
    # channels << :webhook TODO

    channels
  end

  def display_name
    channel_type.humanize
  end
end
