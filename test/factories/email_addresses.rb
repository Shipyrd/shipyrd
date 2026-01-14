FactoryBot.define do
  factory :email_address do
    email { "MyString" }
    user { nil }
  end
end
