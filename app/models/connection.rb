require "base64"

class Connection < ApplicationRecord
  belongs_to :application

  encrypts :key

  enum :provider, github: 0

  validates :provider, presence: true, inclusion: {in: providers.keys}
  validate :connects_successfully, on: :create

  # TODO: Move this to solid_queue
  after_create_commit :import_deploy_recipes

  def connects_successfully
    if fetch_repository_content("config/deploy.yml").present?
      self.last_connected_at = Time.current
    else
      errors.add(:provider, "is not supported")
    end
  rescue
    errors.add(:provider, "#{provider} could not connect")
  end

  def import_deploy_recipes
    base_recipe = fetch_repository_content("config/deploy.yml")

    application.destinations.each do |destination|
      destination.update!(
        recipe: destination.default? ? nil : fetch_repository_content(destination.recipe_path),
        base_recipe: base_recipe,
        recipe_updated_at: Time.current
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
