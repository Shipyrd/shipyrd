require "net/http"
require "json"

class User < ApplicationRecord
  include Role

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :deploys, foreign_key: :performer, primary_key: :username, dependent: :nullify, inverse_of: "user"

  has_secure_password validations: false
  validates :password, length: {minimum: 10, maximum: 72}, if: -> { password.present? }

  validates :username, presence: true, uniqueness: true

  after_create_commit :queue_populate_avatar

  scope :has_role, -> { where.not(role: nil) }
  scope :has_password, -> { where.not(password_digest: nil) }

  attr_accessor :organization_name

  def display_name
    username || name
  end

  def first_letter
    display_name.first
  end

  def queue_populate_avatar
    return false if Rails.env.test? || username.blank?

    AvatarImporterJob.perform_later(id)
  end

  def populate_avatar_url
    url = URI("https://api.github.com/users/#{username}")
    user_info = JSON.parse(Net::HTTP.get(url))

    return if user_info["avatar_url"].blank?

    update!(avatar_url: "#{user_info["avatar_url"]}&s=100")
  end
end
