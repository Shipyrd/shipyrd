FactoryBot.define do
  factory :runner do
    destination { nil }
    command { "MyString" }
    output { "MyText" }
  end
end
