class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show edit update destroy]

  # GET /applications or /applications.json
  def index
    @applications = current_organization.applications.order(created_at: :desc)
  end

  # GET /applications/1 or /applications/1.json
  def show
  end

  def new
    @application = current_organization.applications.new
  end

  def create
    @application = current_organization.applications.new(application_params)

    respond_to do |format|
      if @application.save
        format.html { redirect_to application_url(@application), notice: "Application was successfully created." }
        format.json { render :show, status: :created, location: @application }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @application.errors, status: :unprocessable_content }
      end
    end
  end

  # GET /applications/1/edit
  def edit
  end

  # PATCH/PUT /applications/1 or /applications/1.json
  def update
    respond_to do |format|
      if @application.update(application_params)
        format.html { redirect_to edit_application_url(@application), notice: "Application was successfully updated." }
        format.json { render :show, status: :ok, location: @application }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @application.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /applications/1 or /applications/1.json
  def destroy
    @application.destroy!

    respond_to do |format|
      format.html { redirect_to applications_url, notice: "Application was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application
    @application = current_organization.applications.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def application_params
    params.require(:application).permit(
      :name,
      :repository_url,
      destinations_attributes: %i[id name branch url favicon_url _destroy]
    )
  end
end
