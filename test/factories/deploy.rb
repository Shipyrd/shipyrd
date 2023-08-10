FactoryBot.define do
  factory :deploy do
    application
    recorded_at { Time.now }
    performer { Faker::Name.first_name }
    command { :deploy }
    service_version { "#{application.key}" }
  end
end
