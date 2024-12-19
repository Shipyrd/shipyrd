FactoryBot.define do
  factory :notification do
    event { "lock" }
    destination
    channel
    details { {"locked_at" => Time.current} }
  end
end
