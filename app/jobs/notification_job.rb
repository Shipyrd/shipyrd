class NotificationJob < ApplicationJob
  def perform(id)
    Notification.find(id).notify
  end
end
