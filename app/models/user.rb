require "net/http"
require "json"

class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships, counter_cache: true
  has_many :deploys, foreign_key: :performer, primary_key: :username, dependent: :nullify, inverse_of: "user"

  has_secure_password validations: false
  validates :password, length: {minimum: 10, maximum: 72}, if: -> { password.present? }

  validates :username, allow_blank: true, url: {no_local: true}
  validates :email, uniqueness: true, presence: true, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}

  after_create_commit :queue_populate_avatar

  scope :has_password, -> { where.not(password_digest: nil) }

  attr_accessor :organization_name

  def display_name
    display_username || name
  end

  def first_letter
    display_name.first
  end

  def display_username
    return github_username if github_user?

    username
  end

  def self.lookup_performer(organization_id, performer)
    user = Organization.find(organization_id).users.find_by(username: performer)

    return user.display_name if user

    performer =~ /github\.com/ ? performer.split("/").last : performer
  end

  def github_user?
    username =~ /github\.com/
  end

  def github_username
    return unless github_user?

    username.split("/").last
  end

  def queue_populate_avatar
    return false if Rails.env.test? || !github_user?

    AvatarImporterJob.perform_later(id)
  end

  def populate_avatar_url
    url = URI("https://api.github.com/users/#{github_username}")
    user_info = JSON.parse(Net::HTTP.get(url))

    return if user_info["avatar_url"].blank?

    update!(avatar_url: "#{user_info["avatar_url"]}&s=100")
  end
end
