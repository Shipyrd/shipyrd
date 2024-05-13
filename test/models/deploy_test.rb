require "test_helper"

class DeployTest < ActiveSupport::TestCase
  describe "set_service_name" do
    it "split service_version" do
      assert_equal "app", create(:deploy, service_version: "app@123").service
    end
  end

  describe "compare_url" do
    let(:application) { create(:application, key: "heyo", repository_url: "https://github.com/nickhammond/shipyrd") }

    it "crafts a github link" do
      create(
        :deploy,
        application: application,
        command: :deploy,
        status: "post-deploy",
        version: "previous-sha"
      )
      deploy = create(
        :deploy,
        application: application,
        command: :deploy,
        version: "current-sha"
      )

      assert_equal "#{application.repository_url}/compare/previous-sha...current-sha", deploy.compare_url
    end

    it "renders nil if not github or gitlab" do
      application.update!(repository_url: nil)
      deploy = build(:deploy, application: application)
      assert_nil deploy.compare_url
    end

    it "returns nil if uncommitted version" do
      deploy = build(:deploy, application: application)
      deploy.version = "heyo@uncommitted"
      assert_nil deploy.compare_url
    end
  end

  describe "find_or_create_user" do
    describe "without a known user" do
      it "creates a basic user" do
        assert_difference("User.count") do
          create(:deploy, performer: "greta")
        end
      end

      it "creates a github user" do
        User.any_instance.stubs(:populate_avatar_url)

        assert_difference("User.count") do
          create(:deploy, performer: "https:github.com/nickhammond")
        end
      end
    end

    describe "with a known user" do
      it "points to existing user" do
        user = create(:user, username: "greta")

        deploy = create(:deploy, performer: "greta")

        assert_equal user, deploy.user
      end

      it "points to an existing github user" do
        User.any_instance.stubs(:populate_avatar_url)

        user = create(:user, username: "nickhammond")

        deploy = create(:deploy, performer: "https://github.com/nickhammond")

        assert_equal user, deploy.user
      end
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
        application = create(:application, key: "heyo")

        deploy = create(:deploy, service_version: "heyo@abcdef12")

        assert_equal application, deploy.application
      end
    end
  end

  describe "find or create destination" do
    it "creates the main destination" do
      deploy = create(:deploy, service_version: "heyo@abcdef12")

      assert "main", deploy.application.destinations.first.name
    end

    it "uses existing destination" do
      application = create(:application, key: "heyo")
      application.destinations.create!(name: :production)

      assert_no_difference("Destination.count") do
        assert create(:deploy, service_version: "heyo@abcdef12", destination: :production)
      end
    end
  end
end
