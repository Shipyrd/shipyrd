require "test_helper"

class GithubDeploymentJobTest < ActiveSupport::TestCase
  setup do
    @application = create(:application, repository_url: "https://github.com/kevin/bacon")
    @user = create(:user, username: "https://github.com/kevin")
    @oauth_token = create(:oauth_token, user: @user, provider: :github, application: @application, token: "fake-token")
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

    GithubDeploymentJob.perform_now(deploy.id)

    assert_equal 42, deploy.reload.github_deployment_id
  end

  test "updates github deployment status on post-deploy" do
    create(:deploy,
      application: @application,
      status: "pre-deploy",
      performer: @user.email,
      github_deployment_id: 42)

    post_deploy = create(:deploy,
      application: @application,
      status: "post-deploy",
      performer: @user.email)

    stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments/42/statuses")
      .with(body: hash_including("state" => "success"))
      .to_return(
        status: 201,
        body: {id: 2, state: "success"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    GithubDeploymentJob.perform_now(post_deploy.id)
  end

  test "skips when no github token available" do
    app_without_token = create(:application, repository_url: "https://github.com/kevin/bacon")

    deploy = create(:deploy,
      application: app_without_token,
      status: "pre-deploy",
      performer: "unknown@example.com")

    GithubDeploymentJob.perform_now(deploy.id)

    assert_nil deploy.reload.github_deployment_id
  end

  test "skips when repository is not on github" do
    @application.update!(repository_url: "https://gitlab.com/kevin/bacon")

    deploy = create(:deploy,
      application: @application,
      status: "pre-deploy",
      performer: @user.email)

    GithubDeploymentJob.perform_now(deploy.id)

    assert_nil deploy.reload.github_deployment_id
  end
end
