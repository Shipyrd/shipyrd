FactoryBot.define do
  factory :application do
    name { "Bacon" }
    key { "bacon" }
  end

  factory :application_with_repository_url, parent: :application do
    repository_url { "https://github.com/kevin/bacon" }
  end
end
