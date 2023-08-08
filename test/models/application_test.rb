require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  let(:application) { create(:application) }

  describe "display_name" do
    it "Prefers name over key" do
      application.name = "Bacon"
      assert_equal application.name, application.display_name

      application.name = nil
      assert_equal application.key, application.display_name
    end
  end

  describe "destinations" do
    it "fetches destinations from known deploys" do
      create(:deploy, service: application.key, destination: :production)
      create(:deploy, service: application.key, destination: :staging)

      assert_equal ["production", "staging"], application.destinations
    end

    it "adds in a default destination name" do
      create(:deploy, service: application.key, destination: :production)
      create(:deploy, service: application.key)

      assert_equal ["Production", "Default"], application.destination_names
    end
  end

  describe "current_status" do
    it "fetches latest deploy status" do
      application.deploys.create(
        status: "pre-build",
        command: :deploy,
        destination: :staging
      )
      application.deploys.create(
        status: "post-deploy",
        command: :deploy,
        destination: :staging
      )
      application.deploys.create(
        status: nil,
        command: :app,
        subcommand: :info,
        destination: :staging
      )

      assert_equal "post-deploy", application.current_status(destination: :staging)
    end
  end
end
