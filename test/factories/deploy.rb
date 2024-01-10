FactoryBot.define do
  factory :deploy do
    recorded_at { Time.now }
    performer { Faker::Name.first_name }
    command { :deploy }
    service_version { "test@12345" }
  end
end
