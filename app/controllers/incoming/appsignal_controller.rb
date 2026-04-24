class Incoming::AppsignalController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate

  before_action :validate_event

  def create
    application = IncomingWebhook.find_by!(
      provider: :appsignal,
      token: params[:token]
    ).application

    revision = params[:marker][:revision]

    application.deploys.create!(
      destination: params[:marker][:environment],
      recorded_at: params[:marker][:time],
      version: revision,
      performer: params[:marker][:user],
      command: "deploy",
      status: "post-deploy",
      service_version: "#{application.service}@#{revision.first(7)}"
    )

    head :created
  end

  private

  def validate_event
    head :ok if params[:marker].blank?
  end
end
