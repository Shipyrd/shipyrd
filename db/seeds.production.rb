ApiKey.find_or_create_by!(
  token: ENV["SHIPYRD_API_KEY"]
)
