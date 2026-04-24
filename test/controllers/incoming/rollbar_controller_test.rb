require "test_helper"

class RollbarControllerTest < ActionDispatch::IntegrationTest
  let(:token) { SecureRandom.hex(32) }
  let(:application) { create(:application, service: "app") }
  let(:incoming_webhook) do
    application.incoming_webhooks.create(
      provider: :rollbar,
      token: token
    )
  end

  test "fails on invalid token" do
    post incoming_rollbar_url("invalid"),
      params: {event_name: "deploy"}

    assert_response :not_found
  end

  test "only processes deploy events" do
    IncomingWebhook.expects(:find_by!).never

    post incoming_rollbar_url(incoming_webhook.token),
      params: {event_name: "new_item"}

    assert_response :ok
  end

  test "creates a post-deploy event for succeeded status" do
    rollbar = {
      event_name: "deploy",
      data: {
        deploy: {
          comment: "deploying webs",
          user_id: 1,
          finish_time: 1382656039,
          start_time: 1382656038,
          id: 187585,
          environment: "production",
          project_id: 90,
          local_username: "nick",
          revision: "1234567abcdef",
          status: "succeeded"
        }
      }
    }

    post incoming_rollbar_url(incoming_webhook.token),
      params: rollbar

    deploy = application.deploys.last
    rollbar_deploy = rollbar[:data][:deploy]

    assert_response :created
    assert_equal deploy.destination, rollbar_deploy[:environment]
    assert_equal deploy.recorded_at, Time.zone.at(rollbar_deploy[:finish_time])
    assert_equal deploy.version, rollbar_deploy[:revision]
    assert_equal deploy.performer, rollbar_deploy[:local_username]
    assert_equal deploy.runtime, rollbar_deploy[:finish_time] - rollbar_deploy[:start_time]
    assert_equal deploy.commit_message, rollbar_deploy[:comment]
    assert_equal deploy.status, "post-deploy"
    assert_equal deploy.command, "deploy"
    assert_equal deploy.service_version, "app@1234567"
  end

  test "creates a pre-deploy event for started status" do
    rollbar = {
      event_name: "deploy",
      data: {
        deploy: {
          comment: "deploying webs",
          user_id: 1,
          start_time: 1382656038,
          id: 187585,
          environment: "production",
          project_id: 90,
          local_username: "nick",
          revision: "1234567abcdef",
          status: "started"
        }
      }
    }

    post incoming_rollbar_url(incoming_webhook.token),
      params: rollbar

    deploy = application.deploys.last
    rollbar_deploy = rollbar[:data][:deploy]

    assert_response :created
    assert_equal deploy.destination, rollbar_deploy[:environment]
    assert_equal deploy.recorded_at, Time.zone.at(rollbar_deploy[:start_time])
    assert_equal deploy.version, rollbar_deploy[:revision]
    assert_equal deploy.performer, rollbar_deploy[:local_username]
    assert_nil deploy.runtime
    assert_equal deploy.commit_message, rollbar_deploy[:comment]
    assert_equal deploy.status, "pre-deploy"
    assert_equal deploy.command, "deploy"
    assert_equal deploy.service_version, "app@1234567"
  end

  test "defaults to post-deploy for unrecognized status" do
    rollbar = {
      event_name: "deploy",
      data: {
        deploy: {
          comment: "deploying webs",
          user_id: 1,
          finish_time: 1382656039,
          start_time: 1382656038,
          id: 187585,
          environment: "production",
          project_id: 90,
          local_username: "nick",
          revision: "1234567abcdef",
          status: "failed"
        }
      }
    }

    post incoming_rollbar_url(incoming_webhook.token),
      params: rollbar

    assert_response :created
    assert_equal application.deploys.last.status, "post-deploy"
  end
end
