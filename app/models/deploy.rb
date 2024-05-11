class Deploy < ApplicationRecord
  before_validation :set_service_name
  before_validation :find_or_create_application
  before_validation :find_or_create_user
  before_validation :find_or_create_destination

  belongs_to :application, foreign_key: "service", primary_key: "key", optional: true, touch: true
  belongs_to :user, foreign_key: :performer, primary_key: :username

  validates :recorded_at, :performer, :service_version, :command, presence: true
  validate :service_version_is_valid

  def full_command
    "#{command} #{subcommand}"
  end

  def compare_url
    return nil if /uncommitted/.match?(version)
    return nil if !/(github|gitlab)\.com/.match?(application.repository_url)
    return nil if !previous_deploy

    "#{application.repository_url}/compare/#{previous_deploy.version}...#{version}"
  end

  def previous_deploy
    application.deploys.where(
      destination: destination,
      command: :deploy,
      status: "post-deploy"
    ).where.not(id: id).last
  end

  def performer_avatar
    user&.avatar_url
  end

  # TODO: Just replace the status with an enum? What about custom statuses?
  def progress_value
    case status
    when "pre-connect"
      1
    when "pre-build"
      2
    when "pre-deploy"
      3
    when "post-deploy"
      4
    end
  end

  private

  def service_version_is_valid
    # service@sha
    service_version =~ /\w+@\w+/
  end

  def set_service_name
    return false if service.present? || service_version.blank?

    self.service = service_version.split("@").first
  end

  def find_or_create_application
    return true if application

    create_application!(
      # This is automatically handled in the association but leaving
      # this here to highlight the magic.
      key: service
    )
  end

  def find_or_create_user
    return true if user

    self.user = User.find_or_create_performer(performer)
  end

  def find_or_create_destination
    return true if application.destination_names.include?(destination)

    application.destinations.create(
      name: destination
    )
  end
end
