require "test_helper"

class DeployTest < ActiveSupport::TestCase
  let(:application) { create(:application) }

  describe "set_service_name" do
    it "split service_version" do
      assert_equal "app", create(:deploy, service_version: "app@123", application: application).service
      assert_equal "app", application.service
    end
  end

  describe "user" do
    it "fails to find user" do
      email = "deployer@example.com"
      deploy = build(:deploy, application: application, performer: email)

      assert_nil deploy.user
    end

    it "finds the user via email" do
      user = create(:user)
      deploy = build(:deploy, application: application, performer: user.email)

      assert_equal user, deploy.user
    end
  end

  describe "performer_avatar" do
    it "without a user" do
      deploy = build(:deploy)
      deploy.stubs(:user).returns(nil)

      refute deploy.performer_avatar
    end

    it "with a user" do
      deploy = build(:deploy)
      user = build(:user, avatar_url: "https://google.com")
      deploy.stubs(:user).returns(user)

      assert_equal user.avatar_url, deploy.performer_avatar
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

  describe "destination_deploy_block_state" do
    it "allows deploys when destination does not exist" do
      deploy = build(:deploy, application: application, destination: "production")

      assert deploy.valid?
    end

    it "allows deploys when destination is not locked" do
      application.destinations.create!(name: "production", block_deploys: true)
      deploy = build(:deploy, application: application, destination: "production")

      assert deploy.valid?
    end

    it "blocks deploys when destination is locked by different user" do
      destination = create(:destination, application: application, name: "production", block_deploys: true)
      user = create(:user)
      destination.lock!(user)

      deploy = build(:deploy, application: application, destination: "production", performer: "jim")

      refute deploy.valid?
      assert_includes deploy.errors[:lock], "Destination is currently locked by #{destination.locked_by}"
    end

    it "allows deploys when destination is locked by same user" do
      destination = create(:destination, application: application, name: "production", block_deploys: true)
      user = create(:user)
      destination.lock!(user)

      deploy = build(:deploy, application: application, destination: "production", performer: user.email)

      assert deploy.valid?
    end

    it "blocks deploys outside of business hours" do
      application.organization.update!(
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17
      )
      create(:destination,
        application: application,
        name: "production",
        block_deploys: true,
        auto_lock_outside_business_hours: true
      )

      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 20, 0, 0) do
        deploy = build(:deploy, application: application, destination: "production")

        refute deploy.valid?
        assert_includes deploy.errors[:lock], "Destination is locked outside of business hours"
      end
    end

    it "allows deploys during business hours with auto-lock enabled" do
      application.organization.update!(
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17
      )
      create(:destination,
        application: application,
        name: "production",
        block_deploys: true,
        auto_lock_outside_business_hours: true
      )

      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 12, 0, 0) do
        deploy = build(:deploy, application: application, destination: "production")

        assert deploy.valid?
      end
    end

    it "does not block deploys outside business hours when block_deploys is disabled" do
      application.organization.update!(
        time_zone: "Central Time (US & Canada)",
        business_hours_start: 9,
        business_hours_end: 17
      )
      create(:destination,
        application: application,
        name: "production",
        block_deploys: false,
        auto_lock_outside_business_hours: true
      )

      travel_to Time.find_zone("Central Time (US & Canada)").local(2026, 3, 12, 20, 0, 0) do
        deploy = build(:deploy, application: application, destination: "production")

        assert deploy.valid?
      end
    end
  end
end
