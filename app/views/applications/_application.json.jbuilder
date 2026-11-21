json.extract! application, :id, :name, :slug, :repository_url, :created_at, :updated_at
json.display_name application.display_name

# Kept as bare names for backwards compatibility. `destination_states` carries the
# same destinations with their lock state and latest deploy, so a client can answer
# "what's deployed where" in one request instead of one call per destination.
json.destinations application.destination_names

# `.order(:name)` rather than the association itself on purpose: a scoped call
# bypasses Bullet's N+1 tracking, the same way `destinations.latest` does in the
# HTML views. uniq(&:name) because (application_id, name) is not a unique index —
# `destination_names` dedupes with group(:name) for the same reason.
# includes(:locker) because `locked_by` reads it for every destination, and Bullet
# raises on that N+1 as soon as an application has two of them.
json.destination_states application.destinations.order(:name).includes(:locker).uniq(&:name),
  partial: "destinations/destination", as: :destination
