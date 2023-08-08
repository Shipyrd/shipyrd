require "test_helper"

class DeployTest < ActiveSupport::TestCase
  describe "set_service_name" do
    it "split service_version" do
      assert_equal "app", create(:deploy, service_version: "app@123").service
    end
  end

  describe "compare_url" do
    let(:deploy) { create(:deploy, service_version: "app@123") }

    it "crafts a github link" do
      deploy.application.update(
        repository_url: "https://github.com/nickhammond/shipyrd",
        branch: "custom"
      )

      assert_equal "#{deploy.application.repository_url}/compare/#{deploy.version}...#{deploy.application.branch}", deploy.compare_url
    end

    it "renders nil if not github" do
      assert_nil deploy.compare_url
    end
  end

  describe "find_or_create_application" do
    describe "without a known app" do
      it "creates a basic app with creation" do
        assert_difference("Application.where(key: 'heyo').count") do
          create(:deploy, service_version: "heyo@abcdef12")
        end
      end
    end

    describe "with a known app" do
      it "points to existing app" do
        application = create(:applicaiton, key: "heyo")

        deploy = create(:deploy, service_version: "heyo@abcdef12")

        assert_equal deploy.application, application
      end
    end
  end
end
