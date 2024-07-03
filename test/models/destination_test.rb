require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  it "generates a key pair" do
    application = create(:application)
    destination = create(:destination, application: application, name: "test")

    assert destination.private_key
    assert destination.public_key
  end
end
