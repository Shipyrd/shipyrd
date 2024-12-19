class Notification < ApplicationRecord
  belongs_to :destination
  belongs_to :channel

  after_create :notify_later

  serialize :details, coder: JSON

  def notify_later
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
        user_name: user_name
      )
    )

    update!(notified_at: Time.current)
  end

  def user_name
    if details["performer"].present?
      User.lookup_performer(
        destination.application.organization.id,
        details["performer"]
      )
    elsif details["user_id"].present?
      User.find(details["user_id"]).display_name
    end
  end
end
