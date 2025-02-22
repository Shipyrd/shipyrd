require "test_helper"

class DeployTest < ActiveSupport::TestCase
  let(:application) { create(:application) }

  describe "set_service_name" do
    it "split service_version" do
      assert_equal "app", create(:deploy, service_version: "app@123", application: application).service
    end
  end

  describe "compare_url" do
    it "crafts a github link" do
      application.update!(repository_url: "https://github.com/nickhammond/shipyrd")

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

  describe "dispatches_notifications" do
    it "only for post-deploy events" do
      assert_no_difference("Notification.count") do
        create(:deploy, application: application, service_version: "heyo@abcdef12", status: "pre-deploy")
      end
    end

    it "only when a channel is available" do
      assert_no_difference("Notification.count") do
        create(:destination, application: application, name: "production")

        create(:deploy, application: application, service_version: "heyo@abcdef12", status: "post-deploy", destination: "production")
      end
    end

    it "successfully" do
      assert_difference("Notification.count") do
        create(:destination, application: application, name: "production")
        create(:webhook, application: application)

        create(:deploy, application: application, service_version: "heyo@abcdef12", status: "post-deploy", destination: "production")
      end

      details = Deploy.last.slice(
        :performer,
        :status,
        :version,
        :service_version,
        :hosts,
        :command,
        :subcommand,
        :role,
        :runtime,
        :service,
        :commit_message,
        :compare_url
      )

      assert_equal :deploy, Notification.last.event
      assert_equal details, Notification.last.details.except("recorded_at")
    end
  end

  describe "find or create destination" do
    it "creates a default destination" do
      deploy = create(:deploy, service_version: "heyo@abcdef12", application: application)

      assert_nil deploy.application.destinations.first.name
    end

    it "uses existing destination" do
      create(:deploy, service_version: "heyo@abcdef12", destination: :production, application: application)

      assert_no_difference("Destination.count") do
        assert create(:deploy, service_version: "heyo@abcdef12", destination: :production, application: application)
      end
    end
  end

  describe "find or create servers" do
    it "creates the servers" do
      deploy = create(
        :deploy,
        application: application,
        service_version: "heyo@abcdef12",
        destination: :production,
        hosts: "123.456.789.0,867.53.0.9"
      )

      destination = deploy.application.destinations.find_by(name: :production)

      assert_equal 2, destination.servers.count
      assert_equal %w[123.456.789.0 867.53.0.9], destination.servers.map(&:host)

      assert_no_difference("Server.count") do
        create(
          :deploy,
          application: application,
          service_version: "heyo@abcdef12",
          destination: :production,
          hosts: "123.456.789.0,867.53.0.9"
        )
      end
    end
  end
end
