FactoryBot.define do
  factory :application do
    name { Faker::App.name }
    key { "bacon" }
    organization
  end

  factory :application_with_repository_url, parent: :application do
    repository_url { "https://github.com/kevin/bacon" }
  end
end
