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
end
