json.extract! application, :id, :name, :url, :environment, :repository_url, :created_at, :updated_at
json.url application_url(application, format: :json)
