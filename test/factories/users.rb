FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    name { "MyString" }
    password { "password" }
  end

  factory :admin, parent: :user do
    role { :admin }
  end
end
