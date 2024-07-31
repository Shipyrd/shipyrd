class Connection < ApplicationRecord
  belongs_to :application

  encrypts :key

  enum provider: {
    github: 0
  }

  validates :provider, presence: true
  validate :connects_successfully, on: :create

  def connects_successfully
    if github?
      Github::Client::Repos::Contents.new(oauth_token: key).find(
        path: ".",
        repo: application.repository_name,
        user: application.repository_username
      )
    else
      errors.add(:provider, "is not supported")
    end

    self.last_connected_at = Time.current
  rescue
    errors.add(:provider, "for #{provider} could not connect")
  end
end
