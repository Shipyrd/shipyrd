class AddToButtondownJob < ApplicationJob
  # Repeat signups merge into the existing subscriber instead of failing. The
  # gem sent this for us until 0.3.0 dropped its default, so it is ours to pass
  # now -- without it a second signup on the same address raises
  # Buttondown::EmailAlreadyExistsError.
  COLLISION_BEHAVIOR = "add"

  # ip_address defaults to nil so jobs enqueued outside a request -- the console,
  # a backfill -- still run, and so jobs already queued before this argument
  # existed deserialize.
  def perform(user_id, ip_address: nil)
    user = User.find(user_id)

    attributes = {collision_behavior: COLLISION_BEHAVIOR}
    # Buttondown reads the reader's location and legitimacy off this, and only
    # accepts it at creation. Sent only when we have one, so a request-less job
    # doesn't claim an empty address.
    attributes[:ip_address] = ip_address if ip_address.present?

    Buttondown::Client.new.subscribe(user.email, **attributes)
  end
end
