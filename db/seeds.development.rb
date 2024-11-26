organization = Organization.find_or_create_by!(name: "Initech")

@ai_commit_messages = [
  "Fixed the thing that broke the other thing",
  "Refactored spaghetti code into linguini",
  "Tweaked the font size for cosmic alignment",
  "Repaired the flux capacitor (again)",
  "Optimized for unicorn-powered browsers",
  "Reorganized files like a squirrel on caffeine",
  "Debugged like Sherlock with a magnifying glass",
  "Fixed the bug that turned coffee into decaf",
  "Optimized performance with a sprinkle of fairy dust",
  "Debugged like a detective chasing a pixelated criminal"
]

def create_deploy(application, destination, stage)
  Deploy.create!(
    application: application,
    recorded_at: Time.zone.now,
    status: stage,
    performer: "nickhammond",
    commit_message: @ai_commit_messages.sample,
    version: "7b3c0f04106366acfc7e1fcfe4b2e27f9667f8dc",
    service_version: "#{application.key}@7b3c0f04",
    command: "deploy",
    destination: destination,
    hosts: (application.key == :bacon) ? nil : "123.456.789.0,123.456.789.1,123.456.789.2",
    runtime: (stage == "post-deploy") ? rand(60..119) : nil
  )
end

bacon = organization.applications.find_or_create_by!(key: :bacon)

bacon.update!(
  name: "Bacon",
  key: :bacon,
  repository_url: "https://github.com/nickhammond/bacon"
)

eggs = organization.applications.find_or_create_by!(key: :eggs)

eggs.update!(
  name: "Eggs",
  key: :eggs,
  repository_url: "https://github.com/nickhammond/eggs"
)

ham = organization.applications.find_or_create_by!(key: :ham)

ham.update!(
  name: "Ham",
  key: :ham,
  repository_url: "https://github.com/nickhammond/ham"
)

applications = [bacon, eggs, ham]

stages = %w[pre-connect pre-build pre-deploy post-deploy]

applications[0..1].each do |application|
  %w[staging production].each do |destination|
    state = rand(1..3)

    (1..state).each do |i|
      stage = stages[i]

      create_deploy(application, destination, stage)
    end
  end
end

create_deploy(applications[2], nil, "pre-deploy")

username = `whoami`.strip

user = User.find_or_create_by(email: "#{username}@example.com") do |u|
  u.username = username
  u.password = "password00!"
  organization.memberships.create(user: u, role: :admin)
end

user = User.find_or_create_by(email: "new@example.com") do |u|
  u.username = "newguy"
  u.password = "password00!"
  Organization.find_or_create_by(name: "Fry's Electronics").memberships.create!(user: u, role: :admin)
end
