FactoryBot.define do
  factory :deploy do
    recorded_at { Time.zone.now }
    sequence(:performer) { |n| "Deployer#{n}" }
    command { :deploy }
    service_version { "test@12345" }
    hosts { "123.456.789.0" }
  end
end
