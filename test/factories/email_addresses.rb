FactoryBot.define do
  factory :email_address do
    sequence(:email) { |n| "person#{n}@example.com" }
    user { nil }
  end
end
