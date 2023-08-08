require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  describe "has_secure_token" do
    it "generates a token" do
      assert create(:api_key).token
    end
  end
end
