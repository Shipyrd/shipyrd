FactoryBot.define do
  factory :user do
    email { "hello@world.com" }
    name { "MyString" }
    password { "password" }
    role { :user }
  end
end
