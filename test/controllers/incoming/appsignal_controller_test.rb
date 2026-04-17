require "test_helper"

class AppsignalControllerTest < ActionDispatch::IntegrationTest
  let(:token) { SecureRandom.hex(32) }
  let(:application) { create(:application, service: "app") }
  let(:incoming_webhook) do
    application.incoming_webhooks.create(
      provider: :appsignal,
      token: token
    )
  end

  test "fails on invalid token" do
    post incoming_appsignal_url("invalid"),
      params: {marker: {environment: "production"}}

    assert_response :not_found
  end

  test "creates a deploy event" do
    appsignal = {
      marker: {
        time: "2026-01-13T13:10:04.978277Z",
        environment: "production",
        revision: "1234567abcdef",
        user: "nick",
        site: "My App"
      }
    }

    post incoming_appsignal_url(incoming_webhook.token),
      params: appsignal

    deploy = application.deploys.last
    appsignal_marker = appsignal[:marker]

    assert_response :created
    assert_equal deploy.destination, appsignal_marker[:environment]
    assert_equal deploy.recorded_at, appsignal_marker[:time]
    assert_equal deploy.version, appsignal_marker[:revision]
    assert_equal deploy.performer, appsignal_marker[:user]
    assert_equal deploy.status, "post-deploy"
    assert_equal deploy.command, "deploy"
    assert_equal deploy.service_version, "app@1234567"
  end
end
