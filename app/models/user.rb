require "net/http"
require "json"

class User < ApplicationRecord
  has_many :deploys, foreign_key: :performer, primary_key: :username, dependent: :nullify, inverse_of: "user"

  after_create_commit :queue_import_avatar

  def self.find_or_create_performer(username)
    username, github_user = if /github.com/.match?(username)
      [username.split("/").last, true]
    else
      [username, false]
    end

    user = find_by(username: username)

    return user if user.present?

    user = User.create!(username: username)
    user.populate_avatar_url if github_user

    user
  end

  def queue_import_avatar
    AvatarImporterJob.perform_later(id)
  end

  def populate_avatar_url
    url = URI("https://api.github.com/users/#{username}")
    user_info = JSON.parse(Net::HTTP.get(url))

    return if user_info["avatar_url"].blank?

    update!(avatar_url: "#{user_info["avatar_url"]}&s=100")
  end
end
