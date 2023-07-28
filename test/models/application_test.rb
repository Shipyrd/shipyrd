require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  let(:application) { Application.create(key: "heyo") }

  describe "has many deploys" do
    it "associates via application key" do
      heyo_deploy = Deploy.create(service_version: "heyo@abcdef22")
      Deploy.create(service_version: "other@abcdef22")

      assert_equal application.deploys.first, heyo_deploy
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
        status: "post-deploy",
        destination: :staging
      )

      assert_equal application.current_status(destination: :staging), "post-deploy"
    end
  end
end
