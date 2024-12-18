class Webhook < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :application
  has_one :channel, as: :owner, dependent: :destroy

  after_create :create_channel

  def create_channel
    create_channel!(
      organization: organization,
      application: application,
      channel_type: :webhook,
      events: Channel::EVENTS[:application]
    )
  end
end
