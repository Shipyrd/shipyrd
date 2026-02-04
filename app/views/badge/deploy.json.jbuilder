json.schemaVersion 1
json.label "🚀 #{@destination.name}"
json.color @destination.name == "production" ? "red" : nil

deploy = @destination.latest_post_deploy
json.message deploy.present? ? "#{time_ago_in_words(deploy.recorded_at)} ago" : never
