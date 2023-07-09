json.extract! deploy, :id, :deployed_at, :status, :deployer, :version, :service_version, :hosts, :command, :subcommand, :destination, :role, :runtime, :created_at, :updated_at
json.url deploy_url(deploy, format: :json)
