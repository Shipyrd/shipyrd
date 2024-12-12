FactoryBot.define do
  factory :oauth_tokens do
    token { "MyText" }
    scope { "MyString" }
  end
end
