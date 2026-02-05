FactoryBot.define do
  factory :organization do
    name { "MyString" }
    token { SecureRandom.hex }
    stripe_customer_id { SecureRandom.hex }
  end
end
