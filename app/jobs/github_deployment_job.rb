class GithubDeploymentJob < ApplicationJob
  def perform(deploy_id)
    deploy = Deploy.find(deploy_id)

    case deploy.status
    when "pre-deploy"
      create_deployment(deploy)
    when "post-deploy"
      complete_deployment(deploy)
    end
  end

  private

  def create_deployment(deploy)
    github = github_deployment_for(deploy)
    return unless github

    result = github.create(
      ref: deploy.version,
      environment: deploy.destination.presence || "production",
      description: "Deployed via Shipyrd"
    )

    deploy.update_column(:github_deployment_id, result.id)

    github.create_status(
      deployment_id: result.id,
      state: "in_progress",
      description: "Deploy started"
    )
  end

  def complete_deployment(deploy)
    pre_deploy = deploy.application.deploys.where(
      destination: deploy.destination,
      status: "pre-deploy"
    ).where.not(github_deployment_id: nil).last

    return unless pre_deploy

    github = github_deployment_for(deploy)
    return unless github

    github.create_status(
      deployment_id: pre_deploy.github_deployment_id,
      state: "success",
      description: "Deploy completed"
    )
  end

  def github_deployment_for(deploy)
    return nil unless deploy.application.repository_url&.include?("github.com")

    token = github_token_for(deploy)
    return nil unless token

    repo = "#{deploy.application.repository_username}/#{deploy.application.repository_name}"

    GithubDeployment.new(token: token, repo: repo)
  end

  def github_token_for(deploy)
    deploy.application.oauth_tokens.find_by(provider: :github)&.token
  end
end
