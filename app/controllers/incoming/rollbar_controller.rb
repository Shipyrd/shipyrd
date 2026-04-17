class Incoming::RollbarController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate

  before_action :validate_event

  def create
    application = IncomingWebhook.find_by!(
      provider: :rollbar,
      token: params[:token]
    ).application

    deploy = params[:data][:deploy]

    finish_time = deploy[:finish_time].to_i
    start_time = deploy[:start_time].to_i
    pre_deploy = deploy[:status] == "started"

    application.deploys.create!(
      destination: deploy[:environment],
      recorded_at: pre_deploy ? Time.zone.at(start_time) : Time.zone.at(finish_time),
      version: deploy[:revision],
      performer: deploy[:local_username],
      runtime: pre_deploy ? nil : finish_time - start_time,
      commit_message: deploy[:comment],
      command: "deploy",
      status: pre_deploy ? "pre-deploy" : "post-deploy",
      service_version: "#{application.service}@#{deploy[:revision].first(7)}"
    )

    head :created
  end

  private

  def validate_event
    head :ok if params[:event_name] != "deploy"
  end
end
