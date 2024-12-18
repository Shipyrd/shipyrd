FactoryBot.define do
  factory :channel do
    channel_type { :slack }
    events { ["event1", "event2"] }
  end
end
