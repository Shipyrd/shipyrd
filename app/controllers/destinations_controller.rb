class DestinationsController < ApplicationController
  before_action :set_application
  before_action :set_destination

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  # GET /destinations/1/edit
  def edit
  end

  # GET /destinations/1
  def show
  end

  # PATCH/PUT /destinations/1 or /destinations/1.json
  def update
    respond_to do |format|
      if @destination.update(destination_params)
        format.html { redirect_to application_destination_path(@application, @destination), notice: "Destination was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def lock
    @destination.lock!(current_user)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render :show, status: :ok }
    end
  end

  def unlock
    @destination.unlock!(current_user)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render :show, status: :ok }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application
    @application = current_organization.applications.find(params[:application_id])
  end

  def set_destination
    respond_to do |format|
      format.html do
        # Web usage - treat 'id' parameter as actual ID
        @destination = @application.destinations.find(params[:id])
      end
      format.json do
        # API usage - treat 'id' parameter as destination name
        @destination = @application.destinations.find_by!(name: params[:id])
      end
    end
  end

  def handle_not_found(exception)
    respond_to do |format|
      format.html { raise exception }
      format.json { render json: {error: "Not found"}, status: :not_found }
    end
  end

  # Only allow a list of trusted parameters through.
  def destination_params
    params.require(:destination).permit(:name, :url, :branch, :favicon_url)
  end
end
