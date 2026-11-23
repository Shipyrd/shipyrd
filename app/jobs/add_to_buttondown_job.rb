class AddToButtondownJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)

    # collision_behavior is passed explicitly rather than left to the gem. It
    # defaulted to "add" up to 0.2.x and no longer does, and a repeat signup
    # without it raises EmailAlreadyExistsError, which nothing here rescues --
    # so the job would fail where it used to merge into the existing subscriber.
    Buttondown::Client.new.subscribe(user.email, collision_behavior: "add")
  end
end
