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
    @connection = @application.connections.create!(connection_params)

    respond_to do |format|
      format.html { redirect_to edit_application_url(@application), notice: "Connection was successfully created." }
    end
  end

  def destroy
    @connection.destroy!

    respond_to do |format|
      format.html { redirect_to edit_application_url(@application), notice: "Application was successfully destroyed." }
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

    unless Connection::PROVIDERS.include?(provider)
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
