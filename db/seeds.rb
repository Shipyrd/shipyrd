# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

app = Application.find_or_create_by(name: :apps)

app.update(
  name: 'Apps',
  url: 'https://example.com'
)

stages = %w[pre-connect pre-build pre-deploy post-deploy]

stages.each do |stage|
  Deploy.create(
    deployed_at: Time.now,
    status: 'pre-deploy',
    deployer: 'nick',
    version: '7b3c0f04106366acfc7e1fcfe4b2e27f9667f8dc',
    service_version: 'apps@7b3c0f04',
    command: 'deploy',
    destination: 'staging',
    runtime: stage == 'post-deploy' ? 60 + rand(60) : nil
  )
end
