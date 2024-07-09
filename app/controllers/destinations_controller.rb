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
        format.html { redirect_to edit_application_destination_path(@destination), notice: "Destination was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application
    @application = Application.find(params[:application_id])
  end

  def set_destination
    @destination = @application.destinations.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def destination_params
    params.require(:destination).permit(:name, :url, :branch)
  end
end
