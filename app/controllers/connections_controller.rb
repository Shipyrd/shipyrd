class ConnectionsController < ApplicationController
  before_action :set_application
  before_action :set_connection, only: %i[destroy]
  before_action :verify_provider_parameter, only: %i[new create]

  def index
  end

  def new
    @connection = @application.connections.new(provider: params[:provider])
  end

  def create
    @connection = @application.connections.new(connection_params)

    if @connection.save
      respond_to do |format|
        format.html { redirect_to edit_application_url(@application), notice: "Connection was successfully created." }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @connection.destroy!

    respond_to do |format|
      format.html { redirect_to edit_application_url(@application), notice: "Connection was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_application
    @application = Application.find(params[:application_id])
  end

  def set_connection
    @connection = @application.connections.find(params[:id])
  end

  def verify_provider_parameter
    provider = params[:provider] || connection_params[:provider]

    unless Connection.providers.key?(provider)
      flash[:notice] = "Invalid provider #{provider}"
      redirect_to edit_application_url(@application) and return
    end
  end

  def connection_params
    params.require(:connection).permit(
      :provider,
      :key
    )
  end
end
