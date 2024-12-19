FactoryBot.define do
  factory :webhook do
    user
    application
    url { "https://hook.example.com" }
  end
end
