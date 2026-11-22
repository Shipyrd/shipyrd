class AddToButtondownJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)

    Buttondown::Client.new.subscribe(user.email)
  end
end
