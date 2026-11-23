FactoryBot.define do
  factory :organization do
    name { "MyString" }
    token { SecureRandom.hex }
    stripe_customer_id { SecureRandom.hex }

    trait :subscribed do
      stripe_subscription_id { SecureRandom.hex }
      stripe_subscription_status { "active" }
      last_payment_at { Time.current }
    end
  end
end
