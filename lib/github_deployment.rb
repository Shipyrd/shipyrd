class GithubDeployment
  attr_reader :client, :repo

  def initialize(token:, repo:)
    @client = Octokit::Client.new(access_token: token)
    @repo = repo
  end

  def create(ref:, environment:, description: nil)
    client.create_deployment(
      repo,
      ref,
      environment: environment,
      description: description,
      auto_merge: false,
      required_contexts: []
    )
  end

  def create_status(deployment_id:, state:, description: nil)
    client.post(
      "repos/#{repo}/deployments/#{deployment_id}/statuses",
      state: state,
      description: description
    )
  end
end
