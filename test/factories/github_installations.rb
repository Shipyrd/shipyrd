FactoryBot.define do
  factory :github_installation do
    application
    sequence(:installation_id) { |n| 1_000_000 + n }
  end
end
