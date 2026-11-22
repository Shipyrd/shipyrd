json.extract! application, :id, :name, :slug, :repository_url, :created_at, :updated_at
json.display_name application.display_name

json.destinations application.destination_names

json.destination_states application.destinations_by_name,
  partial: "destinations/destination", as: :destination
