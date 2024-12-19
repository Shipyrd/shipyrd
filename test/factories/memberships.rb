FactoryBot.define do
  factory :membership do
    user
    role { :user }
    organization
  end
end
