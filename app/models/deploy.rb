class Deploy < ApplicationRecord
  before_create :set_service_name
  before_create :find_or_create_application

  belongs_to :application, foreign_key: "service", primary_key: "key", optional: true

  def full_command
    "#{command} #{subcommand}"
  end

  def compare_url
    return nil unless /github\.com/.match?(application.repository_url)

    "#{application.repository_url}/compare/#{version}...#{application.branch}"
  end

  private

  def set_service_name
    return false if service_version.blank?

    self.service = service_version.split("@").first
  end

  def find_or_create_application
    return true if application

    create_application
  end
end
