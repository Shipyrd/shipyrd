FactoryBot.define do
  factory :invite_link do
    role { :user }
    organization
  end
end
