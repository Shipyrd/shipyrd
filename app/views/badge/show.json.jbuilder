json.extract! @destination, :name

if deploy = @destination.latest_post_deploy
  json.deploy do
    json.time_ago "#{time_ago_in_words(deploy.recorded_at)} ago"
    json.performer deploy.performer
  end
end

json.lock do
  json.by @destination.locked_by

  json.time_ago @destination.locked_at.present? ? "#{time_ago_in_words(@destination.locked_at)} ago" : nil
end
