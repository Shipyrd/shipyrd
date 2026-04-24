class Applications::GithubController < ApplicationController
  before_action :set_application

  def show
    @repositories = load_github_repositories
  end

  def update
    value = params.dig(:application, :repository_url)
    installation_id, html_url = value.to_s.split("|", 2)

    if installation_id.blank? || html_url.blank?
      redirect_to application_github_url(@application), alert: "Choose a repository."
      return
    end

    @application.update!(repository_url: html_url)
    github_installation = @application.github_installation || @application.build_github_installation
    github_installation.update!(installation_id: installation_id)

    redirect_to edit_application_url(@application), notice: "Repository connected."
  end

  private

  def set_application
    @application = current_organization.applications.find(params[:application_id])
  end

  def load_github_repositories
    installation_ids = current_organization.applications
      .joins(:github_installation)
      .distinct
      .pluck("github_installations.installation_id")

    @failed_installations = []

    repositories = installation_ids.flat_map do |id|
      repos = GithubAppClient.installation_repositories(id)
      if repos.nil?
        @failed_installations << id
        []
      else
        repos.map { |r| r.merge(installation_id: id) }
      end
    end

    @installation_ids_count = installation_ids.size
    repositories
  end
end
