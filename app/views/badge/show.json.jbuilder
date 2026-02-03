json.extract! @destination, :name

if deploy = @destination.latest_post_deploy
  json.deploy do
    json.time_ago "#{time_ago_in_words(deploy.recorded_at)} ago"
  end
end

json.lock do
  json.by @destination.locked_by.present? ? @destination.locked_by : "unlocked"
end
