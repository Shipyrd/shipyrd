class Incoming::HoneybadgerController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate

  before_action :validate_event

  def create
    application = IncomingWebhook.find_by!(
      provider: :honeybadger,
      token: params[:token]
    ).application

    application.deploys.create!(
      destination: params[:deploy][:environment],
      recorded_at: params[:deploy][:created_at],
      version: params[:deploy][:revision],
      performer: params[:deploy][:local_username],
      command: "deploy",
      status: "post-deploy",
      service_version: "#{application.service}@#{params[:deploy][:revision].first(7)}"
    )

    head :created
  end

  private

  def validate_event
    head :ok if params[:event] != "deployed"
  end
end
