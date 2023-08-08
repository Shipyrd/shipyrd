FactoryBot.define do
  factory :deploy do
    recorded_at { Time.now }
    performer { Faker::Name.first_name }
    command { :deploy }
  end
end
