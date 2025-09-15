require "test_helper"
require "helpers/basic_auth_helpers"

class DeploysControllerTest < ActionDispatch::IntegrationTest
  describe "with api key" do
    setup do
      @application = create(:application)
      @token = @application.token
    end

    test "with invalid API key" do
      assert_no_difference("Deploy.count") do
        post deploys_url,
          params: {
            format: :json,
            deploy: {
              command: "deploy",
              recorded_at: Time.zone.now,
              performer: "nick",
              version: "123456",
              service_version: "potato@123456",
              status: "pre-build"
            }

          },
          headers: auth_headers("invalid")

        assert_response :unauthorized
      end
    end

    test "should create deploy with minimal information" do
      assert_difference("Deploy.count") do
        post deploys_url,
          params: {
            format: :json,
            deploy: {
              command: "deploy",
              recorded_at: Time.zone.now,
              performer: "nick",
              version: "123456",
              service_version: "potato@123456",
              status: "pre-build"
            }

          },
          headers: auth_headers(@token)
      end

      assert_response :created
      assert_equal @application, Deploy.last.application
    end

    test "should create deploy with full information" do
      assert_difference("Deploy.count") do
        post deploys_url,
          params: {
            format: :json,
            deploy: {
              command: "app",
              subcommand: "exec",
              recorded_at: Time.zone.now,
              performer: "nick",
              commit_message: "New fancy things",
              version: "123456",
              service_version: "potato@123456",
              status: "pre-build",
              hosts: "127.0.0.1",
              destination: "production",
              role: "web",
              runtime: 120
            }

          },
          headers: auth_headers(@token)
      end

      assert_response :created
      assert_equal @application, Deploy.last.application
    end

    test "should reject non-JSON requests" do
      post deploys_url,
        params: {
          deploy: {
            command: "deploy",
            recorded_at: Time.zone.now,
            performer: "test",
            version: "123456",
            service_version: "test@123456",
            status: "pre-build"
          }
        },
        headers: auth_headers(@token)

      assert_response :not_acceptable
      response_data = JSON.parse(response.body)
      assert_equal "Only JSON format is supported", response_data["error"]
    end
  end
end
