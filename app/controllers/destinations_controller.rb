class DestinationsController < ApplicationController
  before_action :set_application
  before_action :set_destination

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
    @destination = if request.format.json?
      # API usage - treat 'id' parameter as destination name
      @application.destinations.find_by!(name: params[:id])
    else
      # Web usage - treat 'id' parameter as actual ID
      @application.destinations.find(params[:id])
    end
  end

  # Only allow a list of trusted parameters through.
  def destination_params
    params.require(:destination).permit(:name, :url, :branch)
  end
end
