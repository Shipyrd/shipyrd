class Channel < ApplicationRecord
  belongs_to :organization
  belongs_to :owner, polymorphic: true
  belongs_to :oauth_token, optional: true, dependent: :destroy

  scope :ownerless, -> { where(owner: nil) }

  enum :channel_type, {
    github: 1,
    slack: 2,
    webhook: 3
  }

  serialize :events, coder: JSON
  normalizes :events, with: ->(events) { events.compact_blank }

  EVENTS = {
    application: %w[deploy lock],
    organization: %w[user_joins admin_joins]
  }

  def self.available_channels(owner_type)
    channels = []

    channels << :webhook

    if owner_type == "Application"
      channels << :github if OauthToken.configured_providers.include?("github")
      channels << :slack if OauthToken.configured_providers.include?("slack")
    end

    channels
  end

  def event_scope
    owner_type.underscore.intern
  end

  def display_name
    channel_type.humanize
  end
end
