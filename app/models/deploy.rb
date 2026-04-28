class Deploy < ApplicationRecord
  before_validation :set_service_name
  before_create :find_or_create_destination
  after_create :dispatch_notifications

  belongs_to :application, optional: true, touch: true, inverse_of: "deploys"

  validates :recorded_at, :performer, :service_version, :command, presence: true
  validate :service_version_is_valid, on: :create
  validate :version_is_valid, on: :create
  validate :destination_deploy_block_state, on: :create

  KNOWN_HOOKS = %w[pre-deploy post-deploy failed].freeze

  def full_command
    "#{command} #{subcommand}"
  end

  def compare_url
    return nil if /uncommitted/.match?(version)
    return nil if !/(github|gitlab)\.com/.match?(application.repository_url)
    return nil if !previous_deploy

    "#{application.repository_url}/compare/#{previous_deploy.version}...#{version}"
  end

  def dispatch_notifications
    return false if target_destination.blank?
    return false unless KNOWN_HOOKS.include?(status)

    target_destination.dispatch_notifications(
      :deploy,
      slice(
        :performer,
        :recorded_at,
        :status,
        :version,
        :service_version,
        :hosts,
        :command,
        :subcommand,
        :role,
        :runtime,
        :service,
        :commit_message,
        :compare_url
      ).merge(deploy_id: id)
    )
  end

  def previous_deploy
    application.deploys.where(
      destination: destination,
      command: [:deploy, :setup],
      status: "post-deploy"
    ).where.not(id: id).last
  end

  def user
    @user ||= User.lookup_user(application.organization.id, performer)
  end

  def performer_avatar
    return nil if user.blank?

    user&.avatar_url
  end

  def target_destination
    @target_destination ||= application.destinations.find_by(name: destination)
  end

  def progress_value
    case status
    when "pre-connect" then 1
    when "pre-build" then 2
    when "pre-deploy" then 3
    when "post-deploy" then 4
    when "failed" then 4
    end
  end

  private

  def destination_deploy_block_state
    return true if target_destination.blank?
    return true if !target_destination.block_deploys?

    if target_destination.outside_business_hours?
      errors.add(:lock, "Destination is locked outside of business hours")
      return false
    end

    return true if target_destination.unlocked?
    return true if target_destination.locker == user

    errors.add(:lock, "Destination is currently locked by #{target_destination.locked_by}")
  end

  def version_is_valid
    version =~ /\w+/
  end

  def service_version_is_valid
    # service@sha
    service_version =~ /\w+@\w+/
  end

  def set_service_name
    return false if service.present? || service_version.blank?

    service_name = service_version.split("@").first

    application.update_column(:service, service_name) if application.service.blank?
    self.service = service_name
  end

  def find_or_create_destination
    application.destinations.find_or_create_with_hosts(
      hosts_string: hosts,
      name: destination
    )
  end
end
