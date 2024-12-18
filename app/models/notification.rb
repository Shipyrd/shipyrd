class Notification < ApplicationRecord
  belongs_to :destination
  belongs_to :channel

  after_create :queue_notify

  serialize :details, coder: JSON

  def queue_notify
    NotificationJob.perform_later(id)
  end

  def notify
    return true if notified_at.present?

    channel.owner.notify(event, destination: destination, details: details)

    update!(notified_at: Time.current)
  end
end
