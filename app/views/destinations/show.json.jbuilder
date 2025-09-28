json.extract! @destination, :name, :application_name, :locked_at, :locked_by, :on_deck_url

deploy = @destination.latest_deploy

if deploy
  json.latest_deploy do
    json.recorded_at deploy.recorded_at
    json.status deploy.status
    json.performer deploy.performer
    json.version deploy.version
    json.role deploy.role
    json.runtime deploy.runtime
    json.commit_message deploy.commit_message
    json.compare_url deploy.compare_url
    json.command deploy.command
    json.subcommand deploy.subcommand
  end
end
