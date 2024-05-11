require 'net/http'
require 'json'

class User < ApplicationRecord
  has_many :deploys, foreign_key: :performer, primary_key: :username

  # TODO: Queue with a lite service?
  before_create :populate_avatar_url

  def populate_avatar_url
    return false unless username =~ /github.com/

    self.username = username.split('/').last

    url = URI("https://api.github.com/users/#{username}")
    user_info = JSON.parse(Net::HTTP.get(url))

    return unless user_info['avatar_url'].present?

    self.avatar_url = "#{user_info['avatar_url']}&s=100"
  end
end
