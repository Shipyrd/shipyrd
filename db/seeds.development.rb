ApiKey.find_or_create_by(
  token: ENV['SHIPYRD_API_KEY']
)

app = Application.find_or_create_by(name: :apps)

app.update(
  name: 'Apps',
  url: 'https://example.com'
)

stages = %w[pre-connect pre-build pre-deploy post-deploy]

stages.each do |stage|
  Deploy.create(
    recorded_at: Time.now,
    status: 'pre-deploy',
    performer: 'nick',
    version: '7b3c0f04106366acfc7e1fcfe4b2e27f9667f8dc',
    service_version: 'apps@7b3c0f04',
    command: 'deploy',
    destination: 'staging',
    runtime: stage == 'post-deploy' ? 60 + rand(60) : nil
  )
end
