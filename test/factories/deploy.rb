FactoryBot.define do
  factory :deploy do
    version { "abc1234" }
    recorded_at { Time.zone.now }
    sequence(:performer) { |n| "deployer#{n}@example.com" }
    command { :deploy }
    service_version { "test@12345" }
    hosts { "123.456.789.0" }
  end
end
