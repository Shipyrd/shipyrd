class DeploysController < ApplicationController
  skip_before_action :verify_authenticity_token, if: proc { |c| c.action_name == "create" && request.format.json? }
  before_action :ensure_json_format

  # POST /deploys or /deploys.json
  def create
    @deploy = @application.deploys.new(deploy_params)

    if @deploy.save
      render :show, status: :created, location: @deploy
    else
      render json: @deploy.errors, status: :unprocessable_content
    end
  end

  private

  def ensure_json_format
    unless request.format.json?
      render json: {error: "Only JSON format is supported"}, status: :not_acceptable
    end
  end

  def deploy_params
    params.require(:deploy).permit(
      :recorded_at,
      :status,
      :performer,
      :commit_message,
      :version,
      :service_version,
      :service,
      :hosts,
      :command,
      :subcommand,
      :destination,
      :role,
      :runtime
    )
  end
end
