class DestinationsController < ApplicationController
  before_action :set_application
  before_action :set_destination

  # GET /destinations/1/edit
  def edit
  end

  # GET /destinations/1
  def show
  end

  # GET /destinations/1/deploys
  def deploys
    recent_deploys = @application.deploys
      .where(destination: @destination.name, command: :deploy)
      .order(recorded_at: :desc)
      .limit(120)

    @grouped_deploys = recent_deploys.chunk_while { |a, b|
      a.version == b.version
    }.first(30)
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

  def destroy
    @destination.destroy!
    redirect_to edit_application_path(@application), notice: "Destination was successfully deleted."
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
      id = (params[:id] == "default") ? nil : params[:id]
      @application.destinations.find_by!(name: id)
    else
      # Web usage - treat 'id' parameter as actual ID
      @application.destinations.find(params[:id])
    end
  end

  # Only allow a list of trusted parameters through.
  def destination_params
    params.require(:destination).permit(:name, :url, :branch, :block_deploys, :auto_lock_outside_business_hours)
  end
end
