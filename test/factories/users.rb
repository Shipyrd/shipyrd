FactoryBot.define do
  factory :user do
    username { "MyString" }
    email { "hello@world.com" }
    name { "MyString" }
    password { "password" }
    role { :user }
  end
end
