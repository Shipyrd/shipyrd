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

    channel.owner.notify(
      event,
      details.merge(
        destination_name: destination.name,
        destination_id: destination.id,
        application_name: destination.application.name,
        application_id: destination.application.id,
        user_name: details["user_id"].present? ? User.find(details["user_id"]).display_name : nil
      )
    )

    update!(notified_at: Time.current)
  end
end
