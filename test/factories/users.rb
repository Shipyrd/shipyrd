FactoryBot.define do
  factory :user do
    username { "MyString" }
    email { "MyString" }
    name { "MyString" }
    password { "password" }
    role { :user }
  end
end
