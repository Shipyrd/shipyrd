FactoryBot.define do
  factory :connection do
    provider { "github" }
    key { "key" }
    application { nil }
  end
end
