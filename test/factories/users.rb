FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    name { "MyString" }
    password { "password" }
  end
end
