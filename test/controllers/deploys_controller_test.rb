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

    it "fails when missing deploy details" do
      post deploys_url,
        params: {
          format: :json,
          command: "deploy",
          performer: "nick",
          status: "pre-connect"
        },
        headers: auth_headers(@token)

      assert_response :bad_request
    end

    it "fails when missing required information" do
      post deploys_url,
        params: {
          format: :json,
          deploy: {
            command: "deploy",
            performer: "nick",
            status: "pre-connect"
          }
        },
        headers: auth_headers(@token)

      assert_response :unprocessable_content

      response_data = JSON.parse(response.body)
      assert response_data["errors"]
    end

    describe "bare minimum information" do
      let(:params) do
        {
          format: :json,
          deploy: {
            command: "deploy",
            recorded_at: Time.zone.now,
            performer: "nick",
            version: "123456",
            service_version: "potato@123456",
            status: "pre-build"
          }
        }
      end

      test "should create deploy" do
        assert_difference("Deploy.count") do
          post deploys_url,
            params: params,
            headers: auth_headers(@token)
        end

        assert_response :created
        assert_equal @application, Deploy.last.application
      end

      test "fails when deploy blocking is enabled" do
        destination = @application.destinations.create!
        destination.update(block_deploys: true)

        assert_no_difference("Deploy.count") do
          post deploys_url,
            params: params,
            headers: auth_headers(@token)
        end

        assert_response :unprocessable_content

        response_data = JSON.parse(response.body)
        assert response_data["errors"].key?("lock")
      end
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
