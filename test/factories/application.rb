FactoryBot.define do
  factory :application do
    sequence(:name) { |n| "Application #{n}" }
    key { "bacon" }
    organization
  end

  factory :application_with_repository_url, parent: :application do
    repository_url { "https://github.com/kevin/bacon" }
  end
end
