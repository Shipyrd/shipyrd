class AddToButtondownJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)

    Buttondown.new(ENV.fetch("BUTTONDOWN_API_KEY")).subscribe(user.email)
  end
end
