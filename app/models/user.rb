class User < ApplicationRecord
  # TODO: Queue with a lite service?

  def populate_avatar_url
    url = URI("https://api.github.com/users/#{username}")
    user_info = JSON.parse(Net::HTTP.get(url))

    return unless user_info['avatar_url'].present?

    update(avatar_url: "#{user_info['avatar_url']}&s=100")
  end
end
