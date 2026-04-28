require "test_helper"

class GithubInstallationTest < ActiveSupport::TestCase
  setup do
    @application = create(:application, repository_url: "https://github.com/kevin/bacon")
    @user = create(:user, username: "https://github.com/kevin")
    @github_installation = create(:github_installation, application: @application, installation_id: 123)
    GithubAppClient.stubs(:installation_token).with(123).returns("fake-token")
  end

  test "creates a channel after creation" do
    app = create(:application)

    assert_difference "Channel.count", 1 do
      gi = GithubInstallation.create!(application: app, installation_id: 999)
      assert_equal gi, gi.channel.owner
      assert_equal "github", gi.channel.channel_type
      assert_equal ["deploy"], gi.channel.events
    end
  end

  test "creates github deployment on pre-deploy" do
    deploy = create(:deploy,
      application: @application,
      status: "pre-deploy",
      performer: @user.email)

    stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments")
      .to_return(
        status: 201,
        body: {id: 42, environment: "production"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments/42/statuses")
      .with(body: hash_including("state" => "in_progress"))
      .to_return(
        status: 201,
        body: {id: 1, state: "in_progress"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    @github_installation.notify(:deploy, {
      status: "pre-deploy",
      version: deploy.version,
      destination_name: nil,
      deploy_id: deploy.id
    })

    assert_equal 42, deploy.reload.github_deployment_id
  end

  test "updates github deployment status on post-deploy" do
    pre_deploy = create(:deploy,
      application: @application,
      status: "pre-deploy",
      performer: @user.email,
      github_deployment_id: 42)

    stub = stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments/42/statuses")
      .with(body: hash_including("state" => "success"))
      .to_return(
        status: 201,
        body: {id: 2, state: "success"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    @github_installation.notify(:deploy, {
      status: "post-deploy",
      version: pre_deploy.version,
      destination_name: nil,
      deploy_id: nil
    })

    assert_requested(stub)
  end

  test "marks github deployment as failure on failed status" do
    pre_deploy = create(:deploy,
      application: @application,
      status: "pre-deploy",
      performer: @user.email,
      github_deployment_id: 42)

    stub = stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments/42/statuses")
      .with(body: hash_including("state" => "failure"))
      .to_return(
        status: 201,
        body: {id: 3, state: "failure"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    @github_installation.notify(:deploy, {
      status: "failed",
      version: pre_deploy.version,
      destination_name: nil,
      deploy_id: nil
    })

    assert_requested(stub)
  end

  test "skips when repository is not on github" do
    @application.update!(repository_url: "https://gitlab.com/kevin/bacon")

    deploy = create(:deploy,
      application: @application,
      status: "pre-deploy",
      performer: @user.email)

    @github_installation.notify(:deploy, {
      status: "pre-deploy",
      version: deploy.version,
      destination_name: nil,
      deploy_id: deploy.id
    })

    assert_nil deploy.reload.github_deployment_id
  end

  test "skips non-deploy events" do
    deploy = create(:deploy, application: @application, status: "pre-deploy", performer: @user.email)

    @github_installation.notify(:lock, {status: "pre-deploy", deploy_id: deploy.id})

    assert_nil deploy.reload.github_deployment_id
  end
end
