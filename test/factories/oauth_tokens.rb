FactoryBot.define do
  factory :oauth_token do
    token { "MyText" }
    scope { "MyString" }
  end
end
