json.extract! application, :id, :name, :slug, :repository_url, :created_at, :updated_at
json.display_name application.display_name

# Kept as bare names for backwards compatibility. `destination_states` carries the
# same destinations with their lock state and latest deploy, so a client can answer
# "what's deployed where" in one request instead of one call per destination.
json.destinations application.destination_names

# `destinations_by_name` batch-loads each destination's deploy state, so the
# whole index costs a fixed number of queries rather than four per destination.
json.destination_states application.destinations_by_name,
  partial: "destinations/destination", as: :destination
