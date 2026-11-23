class Current < ActiveSupport::CurrentAttributes
  # The IP the current request came from, so work deferred to a job can report
  # the subscriber's own address rather than the server's.
  attribute :request_ip
end
