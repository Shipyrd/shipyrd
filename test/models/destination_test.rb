require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  it "generates a key pair on create" do
    application = create(:application)
    destination = create(:destination, application: application, name: "test")

    assert destination.private_key
    assert destination.public_key
  end

  it "generates a key pair if missing" do
    application = create(:application)
    destination = create(:destination, application: application, name: "test")

    destination.update_columns(
      private_key: nil,
      public_key: nil
    )

    destination.update!(url: "http://example.com")

    assert destination.private_key
    assert destination.public_key
  end
end
