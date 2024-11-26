FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    name { Faker::Name.first_name }
    password { "secretsecret" }
  end
end
