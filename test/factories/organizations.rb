FactoryBot.define do
  factory :organization do
    name { "MyString" }
    token { SecureRandom.hex }
    stripe_customer_id { SecureRandom.hex }

    # The bare factory is deliberately unsubscribed: `trial_active?` is derived from
    # created_at, so a fresh organization is on trial, which is the 402 case for
    # anything gated on an active subscription.
    trait :subscribed do
      stripe_subscription_id { SecureRandom.hex }
      stripe_subscription_status { "active" }
      last_payment_at { Time.current }
    end
  end
end
