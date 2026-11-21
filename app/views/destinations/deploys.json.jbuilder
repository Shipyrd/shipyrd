json.application do
  json.extract! @application, :id, :name, :slug
  json.display_name @application.display_name
end

json.destination @destination.display_name

# One entry per contiguous run of deploys at the same version, newest first — the
# same grouping the History page renders. `chunk_while` only merges adjacent events,
# so a version that was deployed, superseded, then redeployed appears more than
# once. That is deliberate: those are separate deploys, and collapsing them would
# hide a rollback or a retry. Each entry carries the most recent lifecycle event of
# its own run.
json.deploys @grouped_deploys do |deploy_group|
  deploy = deploy_group.first

  json.version deploy.version
  json.status deploy.status
  json.performer deploy.performer
  json.recorded_at deploy.recorded_at
  json.commit_message deploy.commit_message
  json.runtime deploy.runtime
  json.command deploy.command
  json.subcommand deploy.subcommand
  json.role deploy.role
  json.service_version deploy.service_version
  json.compare_url deploy.compare_url
end
