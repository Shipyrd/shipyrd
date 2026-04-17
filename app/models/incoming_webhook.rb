class IncomingWebhook < ApplicationRecord
  has_secure_token length: 64
  encrypts :token, deterministic: true

  belongs_to :application

  enum :provider, {
    honeybadger: 0,
    rollbar: 1,
    appsignal: 2
  }

  def display_name
    provider.humanize
  end

  def url
    "https://#{ENV["SHIPYRD_HOOKS_HOST"]}/incoming/#{provider}/#{token}"
  end
end
