FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    sequence(:username) { |n| "https://github.com/user#{n}" }
    name { "User" }
    password { "secretsecret" }
    email_verified_at { Time.current }

    trait :unverified do
      email_verified_at { nil }
    end

    trait :grace_period do
      email_verified_at { nil }
      created_at { 1.day.ago }
    end

    trait :verification_required do
      email_verified_at { nil }
      created_at { 8.days.ago }
    end
  end
end
