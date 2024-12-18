FactoryBot.define do
  factory :webhook do
    url { "https://hook.example.com" }
    user { nil }
  end
end
