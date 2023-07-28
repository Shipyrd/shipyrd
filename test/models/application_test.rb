require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  let(:application) { applications(:bacon) }

  describe "display_name" do
    it "Prefers name over key" do
      assert_equal application.name, application.display_name

      application.name = nil
      assert_equal application.key, application.display_name
    end
  end

  describe "has many deploys" do
    it "associates via application key" do
      deploy = Deploy.create(service_version: "bacon@abcdef22")
      Deploy.create(service_version: "other@abcdef22")

      assert_equal application.deploys.last, deploy
    end
  end

  describe "destinations" do
    it "fetches destinations from known deploys" do
      application.deploys.create(service: application.key, destination: "production")
      application.deploys.create(service: application.key, destination: "staging")

      assert_equal application.destinations, ["production", "staging"]
    end
  end

  describe "current_status" do
    it "fetches latest deploy status" do
      application.deploys.create(
        status: "pre-build",
        destination: :staging
      )
      application.deploys.create(
        status: "post-deploy",
        destination: :staging
      )

      assert_equal application.current_status(destination: :staging), "post-deploy"
    end
  end
end
