require "test_helper"

class HoneybadgerControllerTest < ActionDispatch::IntegrationTest
  let(:token) { SecureRandom.hex(32) }
  let(:application) { create(:application, service: "app") }
  let(:incoming_webhook) do
    application.incoming_webhooks.create(
      provider: :honeybadger,
      token: token
    )
  end

  test "fails on invalid token" do
    post incoming_honeybadger_url("invalid"),
      params: {event: "deployed"},
      as: :json

    assert_response :not_found
  end

  test "only processes deployed events" do
    IncomingWebhook.expects(:find_by!).never

    post incoming_honeybadger_url(incoming_webhook.token),
      params: {event: "occurred"},
      as: :json

    assert_response :ok
  end

  test "creates a deploy event" do
    honeybadger = {
      event: :deployed,
      deploy: {
        environment: "production",
        revision: "1234567abcd",
        local_username: "nick",
        created_at: "2026-01-13T13:10:04.978277Z"
      }
    }

    post incoming_honeybadger_url(incoming_webhook.token),
      params: honeybadger,
      as: :json

    deploy = application.deploys.last
    honeybadger_deploy = honeybadger[:deploy]

    assert_response :created
    assert_equal deploy.destination, honeybadger_deploy[:environment]
    assert_equal deploy.recorded_at, honeybadger_deploy[:created_at]
    assert_equal deploy.version, honeybadger_deploy[:revision]
    assert_equal deploy.performer, honeybadger_deploy[:local_username]
    assert_equal deploy.status, "post-deploy"
    assert_equal deploy.command, "deploy"
    assert_equal deploy.service_version, "app@1234567"
  end
end
