class Deploy < ApplicationRecord
  before_create :set_service_name
  before_create :find_or_create_application

  def application
    @application ||= Application.find_by(key: service)
  end

  private

  def set_service_name
    return if service_version.blank?

    self.service = service_version.split("@").first
  end

  def find_or_create_application
    Application.find_or_create_by(key: service)
  end
end
