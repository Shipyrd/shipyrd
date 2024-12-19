FactoryBot.define do
  factory :organization do
    name { "MyString" }
    token { SecureRandom.hex }
  end
end
