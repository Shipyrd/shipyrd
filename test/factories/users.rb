FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    sequence(:username) { |n| "https://github.com/user#{n}" }
    name { "User" }
    password { "secretsecret" }
  end
end
