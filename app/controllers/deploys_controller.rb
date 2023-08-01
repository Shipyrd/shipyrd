class DeploysController < ApplicationController
  skip_before_action :verify_authenticity_token, if: proc { |c| c.action_name == "create" && request.format.json? }
  before_action :set_deploy, only: %i[show edit update destroy]

  # GET /deploys or /deploys.json
  def index
    @deploys = Deploy.all
  end

  # GET /deploys/1 or /deploys/1.json
  def show
  end

  # GET /deploys/new
  def new
    @deploy = Deploy.new
  end

  # GET /deploys/1/edit
  def edit
  end

  # POST /deploys or /deploys.json
  def create
    @deploy = Deploy.new(deploy_params)

    respond_to do |format|
      if @deploy.save
        format.html { redirect_to deploy_url(@deploy), notice: "Deploy was successfully created." }
        format.json { render :show, status: :created, location: @deploy }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @deploy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deploys/1 or /deploys/1.json
  def update
    respond_to do |format|
      if @deploy.update(deploy_params)
        format.html { redirect_to deploy_url(@deploy), notice: "Deploy was successfully updated." }
        format.json { render :show, status: :ok, location: @deploy }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deploy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deploys/1 or /deploys/1.json
  def destroy
    @deploy.destroy!

    respond_to do |format|
      format.html { redirect_to deploys_url, notice: "Deploy was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_deploy
    @deploy = Deploy.find(params[:id])
  end

  def deploy_params
    params.require(:deploy).permit(
      :recorded_at,
      :status,
      :performer,
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
