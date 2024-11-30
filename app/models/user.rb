require "net/http"
require "json"

class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships, counter_cache: true
  has_many :deploys, foreign_key: :performer, primary_key: :username, dependent: :nullify, inverse_of: "user"

  has_secure_password validations: false
  validates :password, length: {minimum: 10, maximum: 72}, if: -> { password.present? }

  validates :username, allow_blank: true, uniqueness: true, url: {no_local: true}

  after_create_commit :queue_populate_avatar

  scope :has_password, -> { where.not(password_digest: nil) }

  attr_accessor :organization_name

  def display_name
    username || name
  end

  def first_letter
    display_name.first
  end

  def github_user?
    username =~ /github\.com/
  end

  def github_username
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
