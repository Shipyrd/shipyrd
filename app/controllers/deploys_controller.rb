class DeploysController < ApplicationController
  skip_before_action :verify_authenticity_token, if: proc { |c| c.action_name == "create" && request.format.json? }

  # POST /deploys or /deploys.json
  def create
    @deploy = Deploy.new(deploy_params)

    respond_to do |format|
      if @deploy.save
        format.json { render :show, status: :created, location: @deploy }
      else
        format.json { render json: @deploy.errors, status: :unprocessable_entity }
      end
    end
  end

  private

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
