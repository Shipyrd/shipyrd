FactoryBot.define do
  factory :incoming_webhook do
    provider { "honeybadger" }
    application { nil }
    token { "MyString" }
  end
end
