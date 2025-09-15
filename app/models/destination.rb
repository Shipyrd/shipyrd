class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  belongs_to :locker, class_name: "User", optional: true, foreign_key: :locked_by_user_id
  has_many :deploys, through: :application
  has_many :servers, dependent: :destroy
  has_many :channels, through: :application

  scope :latest, -> { order(created_at: :desc) }

  broadcasts

  def application_name
    application.name
  end

  def new_servers_available?
    servers.where(last_connected_at: nil).any?
  end

  def dispatch_notifications(event, details)
    channels.each do |channel|
      next unless channel.events.include?(event.to_s)

      channel.notifications.create!(
        event: event,
        destination: self,
        details: details
      )
    end
  end

  def locked?
    locked_at.present?
  end

  def locked_by
    locker&.display_name
  end

  def lock!(user)
    update!(
      locked_at: Time.current,
      locker: user
    )

    dispatch_notifications(:lock, {locked_at: Time.current, user_id: user.id})
  end

  def unlock!(user)
    update!(
      locked_at: nil,
      locker: nil
    )

    dispatch_notifications(:unlock, {user_id: user.id})
  end

  def on_deck_url
    return nil if application.repository_url.blank?
    return nil if latest_deployed_sha.blank? || latest_deployed_sha =~ /uncommitted/
    return nil if branch.blank?

    "#{application.repository_url}/compare/#{latest_deployed_sha}...#{branch}"
  end

  def latest_deployed_sha
    @latest_deployed_sha ||= deploys.where(
      destination: name,
      command: :deploy,
      status: "post-deploy"
    ).last&.version
  end

  def display_name
    name.presence || "default"
  end

  def default?
    name.blank?
  end

  def production?
    name == "production"
  end
end
