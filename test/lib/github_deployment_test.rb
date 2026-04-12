require "test_helper"

class GithubDeploymentTest < ActiveSupport::TestCase
  setup do
    @github_deployment = GithubDeployment.new(token: "fake-token", repo: "kevin/bacon")
  end

  test "create deployment" do
    stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments")
      .with(body: hash_including("ref" => "abc1234", "environment" => "production"))
      .to_return(
        status: 201,
        body: {id: 123, environment: "production"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = @github_deployment.create(
      ref: "abc1234",
      environment: "production",
      description: "Deployed via Shipyrd"
    )

    assert_equal 123, result.id
  end

  test "create deployment status" do
    stub_request(:post, "https://api.github.com/repos/kevin/bacon/deployments/123/statuses")
      .with(body: hash_including("state" => "in_progress"))
      .to_return(
        status: 201,
        body: {id: 456, state: "in_progress"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = @github_deployment.create_status(
      deployment_id: 123,
      state: "in_progress",
      description: "Deploy started"
    )

    assert_equal "in_progress", result.state
  end
end
