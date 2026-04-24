class GithubInstallation < ApplicationRecord
  belongs_to :application
  has_one :channel, as: :owner, dependent: :destroy

  validates :installation_id, presence: true

  after_create :create_channel

  def create_channel
    create_channel!(
      application: application,
      channel_type: :github,
      events: ["deploy"]
    )
  end

  def notify(event, details)
    return unless event == :deploy
    return unless application.hosted_on_github?

    details = details.symbolize_keys
    token = GithubAppClient.installation_token(installation_id)
    return unless token

    client = GithubDeployment.new(token: token, repo: application.repository_full_name)

    case details[:status]
    when "pre-deploy"
      create_deployment(client, details)
    when "post-deploy"
      update_status(client, details, state: "success", description: "Deploy completed")
    when "failed"
      update_status(client, details, state: "failure", description: "Deploy failed")
    end
  end

  private

  def create_deployment(client, details)
    result = client.create(
      ref: details[:version],
      environment: details[:destination_name].presence || "production",
      description: "Tracked by Shipyrd"
    )
    Deploy.find(details[:deploy_id]).update_column(:github_deployment_id, result.id)
    client.create_status(deployment_id: result.id, state: "in_progress", description: "Deploy started")
  end

  def update_status(client, details, state:, description:)
    pre = Deploy
      .where(application_id: application.id,
        destination: details[:destination_name],
        version: details[:version],
        status: "pre-deploy")
      .where.not(github_deployment_id: nil)
      .last
    return unless pre

    client.create_status(deployment_id: pre.github_deployment_id, state: state, description: description)
  end
end
