class AvatarImporterJob < ApplicationJob
  def perform(id)
    User.find(id).populate_avatar_url
  end
end
