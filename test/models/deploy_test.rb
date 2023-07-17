require "test_helper"

class DeployTest < ActiveSupport::TestCase
  describe "find_or_create_application" do
    describe "without a known app" do
      it "creates a basic app with creation" do
        assert_difference("Application.where(key: 'heyo').count") do
          Deploy.create(
            service_version: "heyo@abcdef12"
          )
        end
      end
    end

    describe "with a known app" do
      it "points to existing app" do
        application = Application.create(key: "heyo")

        deploy = Deploy.create(
          service_version: "heyo@abcdef12"
        )

        assert_equal deploy.application, application
      end
    end
  end
end
