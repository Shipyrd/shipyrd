require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  let(:application) { create(:application, key: 'bacon') }

  describe "display_name" do
    it "Prefers name over key" do
      application.name = "Bacon"
      assert_equal application.name, application.display_name

      application.name = nil
      assert_equal application.key, application.display_name
    end
  end

  describe "destinations" do
    let(:service_version) { "#{application.key}@123" }

    it "fetches destinations from known deploys" do
      create(:deploy, service_version: service_version, destination: :production)
      create(:deploy, service_version: service_version, destination: :staging)

      assert_equal ["production", "staging"], application.reload.destination_names
    end

    it "adds in a default destination name" do
      create(:deploy, service_version: service_version)
      create(:deploy, service_version: service_version, destination: :production)

      assert_equal [nil, "production"], application.reload.destination_names
    end
  end

  describe "current_status" do
    it "fetches latest deploy status" do
      create(
        :deploy,
        application: application,
        status: 'pre-build',
        command: :deploy,
        destination: :staging
      )
      create(
        :deploy,
        application: application,
        status: "post-deploy",
        command: :deploy,
        destination: :staging
      )
      create(
        :deploy,
        application: application,
        status: nil,
        command: :app,
        subcommand: :info,
        destination: :staging
      )

      assert_equal "post-deploy", application.current_status(destination: :staging)
    end
  end
end
