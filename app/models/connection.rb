require "base64"

class Connection < ApplicationRecord
  belongs_to :application

  encrypts :key

  enum provider: {
    github: 0
  }

  validates :provider, presence: true, inclusion: {in: providers.keys}
  validate :connects_successfully, on: :create

  def connects_successfully
    if fetch_repository_content(".").present?
      self.last_connected_at = Time.current
    else
      errors.add(:provider, "is not supported")
    end
  rescue
    errors.add(:provider, "#{provider} could not connect")
  end

  def import_destination_deploy_recipes
    application.destinations.each do |destination|
      path = "config/deploy#{destination.name.present? ? ".#{destination.name}" : nil}.yml"

      destination.update!(
        recipe: fetch_repository_content(path)
      )
    end
  end

  private

  def fetch_repository_content(path)
    # Only supports fetching one specific file
    if github?
      contents = Github::Client::Repos::Contents.new(oauth_token: key).find(
        path: path,
        repo: application.repository_name,
        user: application.repository_username
      )

      return nil if contents.blank?

      Base64.decode64(contents.content)
    end
  rescue Github::Error::NotFound
    nil
  end
end
